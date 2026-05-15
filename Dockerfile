# build environment
FROM node:18 AS builder
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app
ENV PATH=/usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json
RUN npm config set strict-ssl false
RUN npm install --legacy-peer-deps
COPY . /usr/src/app
RUN npm run build


# production environment
FROM nginx:alpine
COPY --from=builder /usr/src/app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
