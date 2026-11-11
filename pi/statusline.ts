import { homedir } from "node:os";
import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
	if (count < 1000) return `${count}`;
	if (count < 1_000_000) return `${(count / 1000).toFixed(1)}k`;
	return `${(count / 1_000_000).toFixed(1)}M`;
}

function formatDirectory(cwd: string): string {
	const home = homedir();
	if (cwd === home) return "~";
	if (cwd.startsWith(`${home}/`)) return `~${cwd.slice(home.length)}`;
	return cwd;
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setFooter((tui, theme, footerData) => {
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

			return {
				dispose: unsubscribe,
				invalidate() {},
				render(width: number): string[] {
					let input = 0;
					let output = 0;
					let cost = 0;

					for (const entry of ctx.sessionManager.getBranch()) {
						if (entry.type === "message" && entry.message.role === "assistant") {
							const message = entry.message as AssistantMessage;
							input += message.usage.input;
							output += message.usage.output;
							cost += message.usage.cost.total;
						}
					}

					const branch = footerData.getGitBranch();
					const directory = formatDirectory(ctx.cwd) + (branch ? ` (${branch})` : "");
					const model = ctx.model?.id ?? "no-model";
					const context = ctx.getContextUsage();
					const contextPercent = context?.percent;
					const contextText = contextPercent == null ? "ctx:?" : `ctx:${contextPercent.toFixed(0)}%`;
					const contextColor = contextPercent == null || contextPercent < 50
						? "success"
						: contextPercent < 80
							? "warning"
							: "error";
					const separator = theme.fg("dim", " | ");
					const line = [
						theme.fg("accent", directory),
						theme.fg("muted", model),
						theme.fg(contextColor, contextText),
						theme.fg("warning", `in:${formatTokens(input)} out:${formatTokens(output)}`),
						theme.fg("success", `$${cost.toFixed(2)}`),
					].join(separator);
					const lines = [truncateToWidth(line, width)];
					const statuses = [...footerData.getExtensionStatuses().values()]
						.map((status) => status.replace(/\s+/g, " ").trim())
						.filter(Boolean);

					if (statuses.length > 0) {
						lines.push(truncateToWidth(statuses.join(" "), width));
					}

					return lines;
				},
			};
		});
	});
}
