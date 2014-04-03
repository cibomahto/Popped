class Player
{
  private String m_fileName;
  private String[] lines;
  private int position;

  Player(String fileName) {
    m_fileName = fileName;

    reset();
  }
  
  void reset() {
    lines = loadStrings(m_fileName);
    position = 0;
  }
  
  int getNext() {
    if(position >= lines.length) {
      return -1;
    }
    
    int val = int(lines[position]);
    position++;
    
    return val;
  }
}
