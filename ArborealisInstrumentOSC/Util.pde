// Extract all sub-section of a buffer into another buffer
MultiChannelBuffer getBufferRange(MultiChannelBuffer buf, int start, int length) {
  int nc = buf.getChannelCount();  
  MultiChannelBuffer buf2 = new MultiChannelBuffer(length, nc);
  for (int c = 0; c < nc; c++) {
    float[] frames = buf.getChannel(c);
    float[] subFrames = Arrays.copyOfRange(frames, start, start+length);
     
    subFrames = applyWindow(subFrames);
    buf2.setChannel(c, subFrames);
  }
  return buf2;
}
