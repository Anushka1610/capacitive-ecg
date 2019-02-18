# Capacitive Electrodes
## Signal Collection & Analysis

---

### Arduino Setup

![Pins](img/diagram.png)

---

### Arduino Control

rtbt.ino

![Press Down Key](img/down-arrow.png)

+++?code=rtbt.ino&lang=c

@[1-3](input and BT state)
@[4-15](pin configuration)
@[18-19](analog-input configuration)
@[20](begin Bluetooth Serial)
@[23-26](wait until BT connection established to begin serial transmission)
@[33](read analog input)
@[34](convert to mV)
@[35-36](send voltage and timestamp over serial Bluetooth)
@[37](delay to avoid serial saturation)

---

### Matlab Control

bt_ecg.m

![Press Down Key](img/down-arrow.png)

+++?code=bt_ecg.m&lang=Matlab

