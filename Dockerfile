FROM node:18.20-alpine AS BASE
RUN apk add --no-cache python3 py3-pip

FROM base AS strapi_deps
WORKDIR /app
COPY ./package.json ./package-lock.json* ./
RUN npm ci

FROM base AS strapi_builder
WORKDIR /app
COPY --from=strapi_deps /app/node_modules ./node_modules
COPY ./ ./
RUN NODE_ENV=production npm run build

FROM base as runner
WORKDIR /app
COPY --from=strapi_builder /app ./
# Create user in case they don't exist
RUN npm run strapi admin:create-user -- --firstname=Admin --lastname=User --email=${STRAPI_EMAIL:-admin@mail.com} --password=${STRAPI_PASSWORD:-12345678aA}
# If user exists, set their password to the default
RUN npm run strapi admin:reset-user-password -- --email=${STRAPI_EMAIL:-admin@mail.com} --password=${STRAPI_PASSWORD:-12345678aA}
CMD NODE_ENV=production npm run start
# CMD NODE_ENV=production npm run develop
# CMD sleep infinity