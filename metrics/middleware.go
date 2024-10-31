package metrics

import (
	"net/http"
	"strconv"
	"time"
)

// responseWriter is a custom wrapper for http.ResponseWriter that captures the status code
type responseWriter struct {
	http.ResponseWriter
	statusCode int
}

// WriteHeader intercepts the status code before calling the underlying ResponseWriter
func (rw *responseWriter) WriteHeader(code int) {
	rw.statusCode = code
	rw.ResponseWriter.WriteHeader(code)
}

func Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		// Track concurrent requests
		ConcurrentRequests.Inc()
		defer ConcurrentRequests.Dec()

		// Create a custom response writer to capture the status code
		wrapped := &responseWriter{
			ResponseWriter: w,
			statusCode:     http.StatusOK, // Default to 200 OK
		}

		// Call the next handler with our wrapped response writer
		next.ServeHTTP(wrapped, r)

		// Record metrics after the handler returns
		duration := time.Since(start).Seconds()
		status := strconv.Itoa(wrapped.statusCode)

		RequestDuration.WithLabelValues(
			r.URL.Path,
			r.Method,
			status,
		).Observe(duration)

		RequestsTotal.WithLabelValues(
			r.URL.Path,
			r.Method,
			status,
		).Inc()

		// Record errors if status >= 400
		if wrapped.statusCode >= 400 {
			ErrorsTotal.WithLabelValues(
				r.URL.Path,
				r.Method,
				status,
			).Inc()
		}
	})
}
