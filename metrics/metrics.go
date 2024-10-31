package metrics

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

var (
	// RequestDuration handles the Latency histogram metric
	RequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Request duration in seconds",
			Buckets: []float64{.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10},
		},
		[]string{"handler", "method", "status"},
	)

	// RequestsTotal handles the Traffic counter metric
	RequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"handler", "method", "status"},
	)

	// ErrorsTotal handles the Error rate counter metric
	ErrorsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_errors_total",
			Help: "Total number of HTTP errors",
		},
		[]string{"handler", "method", "status"},
	)

	// ConcurrentRequests handles the Saturation metric
	ConcurrentRequests = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "http_concurrent_requests",
			Help: "Number of concurrent HTTP requests",
		},
	)

	// SignupsTotal handles the Counter metric tracking total signups
	SignupsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "signups_total",
			Help: "Total number of signups",
		},
		[]string{},
	)
)
