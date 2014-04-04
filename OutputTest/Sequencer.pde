
class PopCommand
{
  int m_position;   // Balloon output to pop
  int m_delay;      // Delay before popping the output (ms)
  
  PopCommand(int position, int delay) {
    m_position = position;
    m_delay = delay;
  }
}

class Sequencer
{
  private String m_fileName;
  private int position;
  
  ArrayList<PopCommand> commands;

  Sequencer(String fileName) {
    m_fileName = fileName;

    loadCommands();
  }
  
  void loadCommands() {
    commands = new ArrayList<PopCommand>();
    
    String[] lines = loadStrings(m_fileName);
    for(String line : lines) {
      String[] tokens = line.split(" ");
      int position = int(tokens[0]);
      int delay = int(tokens[1]);
      
      commands.add(new PopCommand(position, delay));
      
      balloonOutputs[position].setColorForeground(color(80,80,0));
    }
    
    position = 0;
  }
  
//  // Get the pop spacing for the next command, but do not increment the position.
//  int getNextPopSpacing() {
//    if(position >= commands.size()) {
//      return -1;
//    }
//    
//    int val = commands.get(position).m_delay;
//    
//    return val;
//  }
//  
//  // Get the balloon for the next command, and increment the position.
//  int getNext() {
//    if(position >= commands.size()) {
//      return -1;
//    }
//    
//    int val = commands.get(position).m_position;
//    position++;
//    
//    return val;
//  }
  
  PopCommand getNextCommand() {
    if(position >= commands.size()) {
      return new PopCommand(-1, -1);
    }
    
    PopCommand nextCommand = commands.get(position);
    position++;
    
    return nextCommand;
  }
  
  int getRemainingTime() {
    int remainingTime = 0;
    
    // Ignore the last timing delay, nothing comes after it.
    for(int i = position; i < commands.size() - 1; i++) {
      remainingTime += commands.get(i).m_delay;
    }
    
    return remainingTime;
  }
}
