package apigen

import (
    "net/http"
    "github.com/gin-gonic/gin"
)

// Ensure this type satisfies the generated interface once present.
var _ ServerInterface = (*ServerImpl)(nil)

type ServerImpl struct{}

// Example fallback handler to be used by unimplemented operations.
func notImplemented(c *gin.Context) {
    c.JSON(http.StatusNotImplemented, gin.H{"message": "not implemented"})
}