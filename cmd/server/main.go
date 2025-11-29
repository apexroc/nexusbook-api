package main

import (
    "log"
    "github.com/gin-gonic/gin"
    apigen "github.com/apexroc/nexusbook-api/server/apigen"
)

func main() {
    r := gin.Default()

    impl := &apigen.ServerImpl{}
    apigen.RegisterHandlers(r, impl)

    log.Println("Starting Gin server on :8080")
    if err := r.Run(":8080"); err != nil {
        log.Fatal(err)
    }
}

// Handlers are implemented in server/apigen (ServerImpl)