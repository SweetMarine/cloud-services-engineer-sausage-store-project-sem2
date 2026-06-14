FROM node:16-alpine AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build -- --prod --aot=false --build-optimizer=false

FROM nginx:1.27-alpine

COPY --from=build /app/dist/frontend /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
