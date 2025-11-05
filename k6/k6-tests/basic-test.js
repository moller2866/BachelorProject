import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
};

// Loki creates 6 logs per /todos call
export default function () {
  http.get('http://localhost:8080/todos');
  sleep(1);
}
