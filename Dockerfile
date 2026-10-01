# NOURA API + worker image (one image, two process roles; blueprint §2).
#   API:    docker run ... noura node apps/api/dist/server.js
#   Worker: docker run ... noura node apps/worker/dist/worker.js
#   Queue schema release step: docker run ... noura node apps/worker/dist/queue-migrate.js
# Not yet built in this environment (no Docker daemon); see docs/milestones.md.

FROM node:22.22.0-bookworm-slim AS build
ENV PNPM_HOME=/pnpm PATH=/pnpm:$PATH
RUN corepack enable
WORKDIR /repo
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc tsconfig.base.json ./
COPY apps/api/package.json apps/api/
COPY apps/worker/package.json apps/worker/
COPY packages/contracts/package.json packages/contracts/
COPY packages/domain/package.json packages/domain/
COPY packages/ai/package.json packages/ai/
COPY supabase/package.json supabase/
RUN pnpm install --frozen-lockfile --ignore-scripts
COPY apps/api apps/api
COPY apps/worker apps/worker
COPY packages packages
RUN pnpm --filter @noura/contracts --filter @noura/domain --filter @noura/ai run build \
 && pnpm --filter @noura/api --filter @noura/worker run build \
 && pnpm install --frozen-lockfile --prod --ignore-scripts

FROM node:22.22.0-bookworm-slim AS runtime
ENV NODE_ENV=production
WORKDIR /repo
COPY --from=build --chown=node:node /repo /repo
USER node
EXPOSE 8080 8081
CMD ["node", "apps/api/dist/server.js"]
