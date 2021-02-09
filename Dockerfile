# Build frontend
FROM node:latest as build-stage

WORKDIR /app
COPY ./frontend/package.json ./
COPY ./frontend/yarn.lock ./
RUN yarn install
COPY ./frontend .
RUN yarn build

# Build app
FROM golang:alpine as production-stage

ENV GO111MODULE=on \
    CGO_ENABLED=1 \
    GOOS=linux \
    GOARCH=amd64 \
    PORT=8080

WORKDIR /build

RUN apk update && apk add gcc build-base
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .
RUN go build -o main .
WORKDIR /prod
RUN cp /build/main .

# Copy frontend files
RUN mkdir -p /prod/frontend/dist
COPY --from=build-stage /app/dist /prod/frontend/dist

EXPOSE ${PORT}

CMD ["/prod/main"]