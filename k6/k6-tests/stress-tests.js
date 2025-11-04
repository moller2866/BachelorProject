import { Counter } from "k6/metrics";
import { sleep } from "k6";

// Define a custom metric to simulate logs
export const logCounter = new Counter("synthetic_logs");

// Test options
export const options = {
  vus: 24,           // 24 virtual users → roughly 24 logs/sec
  duration: "1h",   // simulate full-day load
};

export default function () {
  // Simulate a log entry
  logCounter.add(1);

  // Optionally, include some variation in log content
  const logEntry = {
    timestamp: Date.now(),
    level: "info",
    message: `Synthetic log from VU ${__VU}`,
    user: `user-${__VU}`,
  };

  // Wait 1 second before next iteration to control log rate
  sleep(1);
}
