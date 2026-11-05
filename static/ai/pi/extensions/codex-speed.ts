import { homedir } from "node:os";
import { relative, sep } from "node:path";
import type {
  ExtensionAPI,
  ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type SpeedMode = "off" | "fast" | "ultrafast";
const stateKey = Symbol.for("ethan.pi.codex-speed");

// Pi recreates extension factories on /new and /reload; only the preference is process-owned.
const processState = globalThis as typeof globalThis & {
  [stateKey]?: { mode: SpeedMode };
};
const state = (processState[stateKey] ??= { mode: "off" });

function formatTokens(value: number): string {
  if (value < 1000) return String(value);
  if (value < 10000) return `${(value / 1000).toFixed(1)}k`;
  if (value < 1000000) return `${Math.round(value / 1000)}k`;
  if (value < 10000000) return `${(value / 1000000).toFixed(1)}M`;
  return `${Math.round(value / 1000000)}M`;
}

export default function codexSpeed(pi: ExtensionAPI): void {
  function updateFooter(ctx: ExtensionContext): void {
    if (ctx.mode !== "tui") return;
    if (state.mode === "off" || ctx.model?.provider !== "openai-codex") {
      ctx.ui.setFooter(undefined);
      return;
    }

    ctx.ui.setFooter((tui, _theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());
      let cachedLeaf: string | null | undefined;
      let totals = {
        input: 0,
        output: 0,
        cacheRead: 0,
        cacheWrite: 0,
        cost: 0,
      };
      let cacheHitRate: number | undefined;

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          const theme = ctx.ui.theme;
          const dim = (text: string) => theme.fg("dim", text);
          const leaf = ctx.sessionManager.getLeafId();
          if (leaf !== cachedLeaf) {
            totals = {
              input: 0,
              output: 0,
              cacheRead: 0,
              cacheWrite: 0,
              cost: 0,
            };
            cacheHitRate = undefined;
            for (const entry of ctx.sessionManager.getEntries()) {
              const usage =
                entry.type === "message"
                  ? entry.message.role === "assistant" ||
                    entry.message.role === "toolResult"
                    ? entry.message.usage
                    : undefined
                  : entry.type === "usage" ||
                      entry.type === "compaction" ||
                      entry.type === "branch_summary"
                    ? entry.usage
                    : undefined;
              if (!usage) continue;
              totals.input += usage.input;
              totals.output += usage.output;
              totals.cacheRead += usage.cacheRead;
              totals.cacheWrite += usage.cacheWrite;
              totals.cost += usage.cost.total;
              if (
                entry.type === "message" &&
                entry.message.role === "assistant"
              ) {
                const promptTokens =
                  usage.input + usage.cacheRead + usage.cacheWrite;
                cacheHitRate =
                  promptTokens > 0
                    ? (usage.cacheRead / promptTokens) * 100
                    : undefined;
              }
            }
            cachedLeaf = leaf;
          }

          const cwd = ctx.sessionManager.getCwd();
          const homeRelative = relative(homedir(), cwd);
          let location =
            homeRelative === ""
              ? "~"
              : homeRelative !== ".." && !homeRelative.startsWith(`..${sep}`)
                ? `~${sep}${homeRelative}`
                : cwd;
          const branch = footerData.getGitBranch();
          if (branch) location += ` (${branch})`;
          const name = ctx.sessionManager.getSessionName();
          if (name) location += ` • ${name}`;

          const stats: string[] = [];
          if (totals.input) stats.push(`↑${formatTokens(totals.input)}`);
          if (totals.output) stats.push(`↓${formatTokens(totals.output)}`);
          if (totals.cacheRead)
            stats.push(`R${formatTokens(totals.cacheRead)}`);
          if (totals.cacheWrite)
            stats.push(`W${formatTokens(totals.cacheWrite)}`);
          if (
            (totals.cacheRead || totals.cacheWrite) &&
            cacheHitRate !== undefined
          ) {
            stats.push(`CH${cacheHitRate.toFixed(1)}%`);
          }
          const subscription =
            ctx.model && ctx.modelRegistry.isUsingOAuth(ctx.model);
          if (totals.cost || subscription)
            stats.push(
              `$${totals.cost.toFixed(3)}${subscription ? " (sub)" : ""}`,
            );
          const context = ctx.getContextUsage();
          const percent = context?.percent;
          const contextWindow =
            context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const auto =
            pi.getSettings().compaction?.enabled !== false ? " (auto)" : "";
          const contextText = `${percent === null ? "?" : `${(percent ?? 0).toFixed(1)}%`}/${formatTokens(contextWindow)}${auto}`;
          const contextColor =
            (percent ?? 0) > 90
              ? "error"
              : (percent ?? 0) > 70
                ? "warning"
                : "dim";
          stats.push(theme.fg(contextColor, contextText));

          let model = ctx.model?.id ?? "no-model";
          if (ctx.model?.reasoning) {
            const thinking = pi.getThinkingLevel();
            model += thinking === "off" ? " • thinking off" : ` • ${thinking}`;
          }
          const label = state.mode === "fast" ? "Fast" : "Ultrafast";
          const speed = theme.fg(
            state.mode === "fast" ? "accent" : "warning",
            label,
          );
          const provider = `(${ctx.model?.provider}) `;
          if (
            footerData.getAvailableProviderCount() > 1 &&
            visibleWidth(stats.join(" ")) +
              visibleWidth(provider + model) +
              visibleWidth(speed) +
              3 <=
              width
          ) {
            model = provider + model;
          }
          const modelWidth = Math.max(0, width - visibleWidth(speed) - 1);
          const right = `${truncateToWidth(dim(model), modelWidth, "")} ${speed}`;
          const available = Math.max(0, width - visibleWidth(right) - 2);
          const left = truncateToWidth(dim(stats.join(" ")), available, "");
          const padding = " ".repeat(
            Math.max(0, width - visibleWidth(left) - visibleWidth(right)),
          );
          const lines = [
            truncateToWidth(dim(location), width),
            truncateToWidth(left + padding + right, width),
          ];
          const statuses = [...footerData.getExtensionStatuses()]
            .sort(([a], [b]) => a.localeCompare(b))
            .map(([, text]) =>
              text
                .replace(/[\r\n\t]/g, " ")
                .replace(/ +/g, " ")
                .trim(),
            );
          if (statuses.length)
            lines.push(truncateToWidth(statuses.join(" "), width));
          return lines;
        },
      };
    });
  }

  for (const mode of ["fast", "ultrafast"] as const) {
    pi.registerCommand(mode, {
      description: `Toggle ${mode === "fast" ? "priority" : "ultrafast"} tier requests for OpenAI Codex (this Pi process only)`,
      handler: async (_args, ctx) => {
        state.mode = state.mode === mode ? "off" : mode;
        updateFooter(ctx);
      },
    });
  }

  pi.on("session_start", (_event, ctx) => updateFooter(ctx));
  pi.on("model_select", (_event, ctx) => updateFooter(ctx));
  pi.on("before_provider_request", (event, ctx) => {
    if (state.mode === "off" || ctx.model?.provider !== "openai-codex") return;
    return {
      ...(event.payload as Record<string, unknown>),
      service_tier: state.mode === "fast" ? "priority" : "ultrafast",
    };
  });
}
