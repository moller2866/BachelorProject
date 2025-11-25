import http from 'k6/http';
import { sleep } from 'k6';

// 2 million requests per 24 hours:
// 2,000,000 / 86400 = 23.148 requests/sec.

// With standard configuration, Loki seems to break at around 570 requests/sec
const START_RPS = 100;

// Target RPS after ramp-up.
// You can increase this if your cluster is strong.
const TARGET_RPS = 600;

const RAMP_DURATION = '2m';

// Steady load at max RPS for observation after ramp up 
const HOLD_DURATION = '1m';

export const options = {
  scenarios: {
    break_loki: {
      executor: 'ramping-arrival-rate',

      // Start at the minimal load we want to test
      startRate: START_RPS,

      // Smooth rate increases via a time-series
      timeUnit: '1s',

      preAllocatedVUs: 50,  // k6 will scale VUs as needed
      maxVUs: 2000,

      stages: [
        // Ramp from 23 req/sec → TARGET_RPS over 1 hour.
        { target: TARGET_RPS, duration: RAMP_DURATION },

        // Hold max throughput for monitoring.
        { target: TARGET_RPS, duration: HOLD_DURATION },

        // Ramp down to zero after test.
        { target: 0, duration: '30s' },
      ],
    },
  },

  // We don't care about response failures here — Loki capacity is the focus.
  thresholds: {
    http_req_failed: ['rate<1'], // allow some failures — we're pushing the system.
  }
};

export default function () {
  http.get('http://localhost:8080/todos');
  // no sleep in arrival-rate tests.
}
