FROM golang:1.23 AS base 
#Using  Go language as base image, then given version and creating a alias for the stage 1 because we are going to multistage docker file

WORKDIR /app
#Setup a work directory for this docker image, all the commands after this will get executed inside this work directory.

COPY go.mod ./
#Copy the go.mod. Dependencies for the applications are stored in go.mod. 

RUN go mod download
#Any dependecncies for the application will be downloaded from go.mod

COPY . .
#Copy the source code to docker image

RUN go build -o /main .
#Run the application -> after this artifact or binary called main will be created in the docker image.

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o main .
# Force static build and correct OS/Arch

#######################################################
# Reduce the image size using multi-stage builds
# We will use a distroless image to run the application

FROM gcr.io/distroless/base
#Popular disotless image is gcr

COPY --from=base /app/main .
#Copy the main binary in /app directory from the base stage to the default directory(.).

COPY --from=base /app/static ./static
#Along witht the binary also copy the static files(that are not bundled in the binary).

EXPOSE 8080
#Expose the port to 8080.

CMD ["./main"]
#Run the application.