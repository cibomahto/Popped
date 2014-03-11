class Protocol
{
  private String m_portName;
  private Serial m_outPort;

  Protocol(PApplet parent, String portName) {
    m_portName = portName;

    println("Connecting to device on: " + portName);
    m_outPort = new Serial(parent, portName, 115200);
  }
  
  void sendUpdate(int[] payload) {
    // 2 bytes for the header
    // 1 byte for the length
    // n bytes for the payload
    // 1 byte for the CRC
    byte data[] = new byte[3+payload.length*2+1];

    data[0] = (byte)0xde;
    data[1] = (byte)0xad;
    data[2] = (byte)(payload.length*2);
    for (int i = 0; i < payload.length; i++) {
      data[3+i*2] =   (byte)((payload[i])      & 0xFF); // low byte
      data[3+i*2+1] = (byte)((payload[i] >> 8) & 0xFF); // high byte
    }

    IButtonCrc crc = new IButtonCrc();
    for (int i = 0; i <  data.length - 1; i++) {
      crc.update(data[i]);
    }
    
    data[data.length-1] = crc.getCrc();

    m_outPort.write(data);
    
//    print("length:");
//    println(data.length);
//    for(int i = 0; i < data.length; i++) {
//      print(int(data[i]));
//      print(" ");
//    }
//    println("");
  }
}

/**
 * This is a Java implementation of the IButton/Maxim 8-bit CRC. Code ported
 * from the AVR-libc implementation, which is used on the RR3G end.
 * Taken from the ReplicatorG sources:
 * https://github.com/cibomahto/ReplicatorG/blob/master/src/replicatorg/app/tools/IButtonCrc.java
 */
public class IButtonCrc {

  private int crc = 0;

  /**
   	 * Construct a new, initialized object for keeping track of a CRC.
   	 */
  public IButtonCrc() {
    crc = 0;
  }

  /**
   	 * Update the CRC with a new byte of sequential data. See
   	 * include/util/crc16.h in the avr-libc project for a full explanation of
   	 * the algorithm.
   	 * 
   	 * @param data
   	 *            a byte of new data to be added to the crc.
   	 */
  public void update(byte data) {
    crc = (crc ^ data) & 0xff; // i loathe java's promotion rules
    for (int i = 0; i < 8; i++) {
      if ((crc & 0x01) != 0) {
        crc = ((crc >>> 1) ^ 0x8c) & 0xff;
      } 
      else {
        crc = (crc >>> 1) & 0xff;
      }
    }
  }

  /**
   	 * Get the 8-bit crc value.
   	 */
  public byte getCrc() {
    return (byte) crc;
  }

  /**
   	 * Reset the crc.
   	 */
  public void reset() {
    crc = 0;
  }
}

