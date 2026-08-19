/**
 * dsh-launchpad — a DeepSeek Harness server plugin.
 *
 * Hosts two endpoints on the DSH web server:
 *
 *   GET /launchpad           → the splash / loading page (assets/loading.html)
 *   GET /launchpad/status    → JSON readiness probe for the loading page
 *
 * The loading page polls /launchpad/status until the server answers, then
 * redirects into the app. On top of the plugin, the package ships Windows
 * launcher scripts (scripts/) that start dsh silently and open the loading
 * page, and an idle watcher that stops dsh shortly after the browser tab
 * closes.
 */
import { readFileSync } from "node:fs";

const loadingHtml = readFileSync(
  new URL("../assets/loading.html", import.meta.url),
  "utf8",
);

const STATUS_JSON = () =>
  JSON.stringify({
    ok: true,
    service: "dsh",
    pid: process.pid,
    uptime: Math.round(process.uptime()),
    time: Date.now(),
  });

const CACHE_BUST = "no-cache, no-store, must-revalidate";

function send(res, status, body, contentType) {
  res.writeHead(status, {
    "content-type": contentType,
    "cache-control": CACHE_BUST,
    "content-length": Buffer.byteLength(body),
  });
  res.end(body);
}

export function apply(ctx, config) {
  const startedAt = Date.now();
  ctx.effect(
    () =>
      ctx.webServer.register({
        kind: "prefix",
        path: "/launchpad",
        handler: async (req, res) => {
          const url = (req.url ?? "").split("?")[0];
          if (req.method === "GET" && (url === "/launchpad" || url === "/launchpad/")) {
            return send(res, 200, loadingHtml, "text/html; charset=utf-8");
          }
          if (req.method === "GET" && url === "/launchpad/status") {
            return send(res, 200, STATUS_JSON(), "application/json; charset=utf-8");
          }
          send(res, 404, "not found", "text/plain; charset=utf-8");
        },
      }),
    "dsh-launchpad routes",
  );
  ctx.logger?.info?.(
    `[dsh-launchpad] ready at /launchpad (boot ${Date.now() - startedAt}ms)`,
  );
}
