import buffer from 'node:buffer';

if (!buffer.SlowBuffer) {
  buffer.SlowBuffer = buffer.Buffer;
}
