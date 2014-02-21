#
# modified from index.js
#

module BeagleBone

  @@gpio = []
  @@pwm = {}
  @@capemgr = nil
  @@ainPrefix = nil
  @@indexOffset = nil
  @@scale = nil


  def callInterval (interval)
    pid = Process::fork
    if !pid
      while true
        sleep(interval)
        yield
      end
    end
    pid
  end

  def callTimeout (time)
    pid = Process::fork
    if !pid
      sleep(time)
      yield
      exit 0
    end
    pid
  end


  def file_find (path, prefix, attempts = 1)
    attempts.times do
      file = Dir.entries(path).find{|x| x.index(prefix) == 0}
      return "#{path}/#{file}" if file
    end
    nil
  end


  def readTextFile (path, mode = "r")
    x = nil
    File.open(path, mode) {|fh| x = fh.read}
    x
  end

  def writeTextFile (path, data, mode = "w")
    File.open(path, mode) {|fh| fh.write(data.to_s)}
  end


  def is_capemgr ()
    if @@capemgr == nil
      @@capemgr = file_find('/sys/devices', 'bone_capemgr.')
      @@capemgr = false unless @@capemgr
    end
    @@capemgr
  end


  def load_dt (name)
    return false unless is_capemgr()
    slotsName = @@capemgr + '/slots'
    slots = readTextFile(slotsName)
    unless slots.index(name) 
      writeTextFile(slotsName, name)
    end
    10000.times do
      slots = readTextFile(slotsName)
      return true if slots.index(name)
    end
    false
  end


  def getpin (pin)
    case pin
    when String
      PINS[pin]
    when Numeric
      PIN_INDEX[pin]
    when Object
      pin
    else
      raise "Invalid pin: #{pin}"
    end
  end


  def getPinMode (pin, &block)
    pin = getpin(pin)
    mode = {'pin' => pin['key'], 'name' => pin['name']}
    mode['options'] = pin['options'] if (pin['options'])
    muxFile = pin['mux'] ? ('/sys/kernel/debug/omap_mux/' + pin['mux']) : nil
    pinctrlFile = '/sys/kernel/debug/pinctrl/44e10800.pinmux/pins';

    if muxFile and File.exist? muxFile
      data = readTextFile(muxFile)
      mode = Parse::modeFromOmapMux(data, mode)
    elsif File.exist? pinctrlFile
      data = readTextFile(pinctrlFile)
      mode = Parse::modeFromPinctrl(data, pin['muxRegOffset'], 0x44e10800, mode)
    else
      # no valid mux data
    end
    block(mode) if block
    mode
  end


  def pinMode (pin, direction, mux = 7, pullup = nil, slew = 'fast', &block)
    pin = getpin(pin)
    pullup = 'pullup' if direction == INPUT_PULLUP
    pullup ||= (direction == INPUT) ? 'pulldown' : 'disabled'
    n = pin['gpio']
    
    raise "Invalid pin object for pinMode: #{pin}" unless pin['mux']

    muxFile = "/sys/kernel/debug/omap_mux/#{pin['mux']}"
    gpioFile = "/sys/class/gpio/gpio#{n}/value"

    led = pin['led']
    if led
      if (direction != OUTPUT) || (mux != 7)
        err = "pinMode only supports GPIO output for LEDs: #{pin['key']}"
        block({'value' => false, 'err' => err}) if block
        return false
      end
      gpioFile = "/sys/class/leds/beaglebone::#{led}/brightness"
      pathA = "/sys/class/leds/beaglebone:"
      pathB = pathA
      pathA += ":#{led}/trigger"
      pathB += "green:#{led}/trigger"
      if File.exist? pathA
        writeTextFile(pathA, 'gpio')
      elsif File.exist? pathB
        writeTextFile(pathB, 'gpio')
      else
        STDERR.puts "Unable to find LED: #{led}"
      end
      @@gpio[n] = {'path' => gpioFile}
      block({'value' => true}) if block
      return true
    end

    pinData = 0
    pinData |= 0x40 if (slew == 'slow')
    pinData |= 0x20 if (direction != OUTPUT)
    pinData |= 0x08 if (pullup == 'disabled')
    pinData |= 0x10 if (pullup == 'pullup')
    pinData |= (mux & 0x07)

    unless is_capemgr()
      begin
        writeTextFile(muxFile, pinData.to_s(16))
      rescue => ex
        STDERR.puts "Unable to configure mux for pin #{pin}: #{ex}"
        currentMode = getPinMode(pin)
        STDERR.puts "mode = #{currentMode.inspect}"
        if currentMode['mux'] != mux
          err2 = "Unable to configure mux for pin #{pin['key']}: #{ex}"
          STDERR.puts err2
          @@gpio[n] = {}
          block({'value' => false, 'err' => err2}) if block
          return false
        end
      end
    end

    if (mux == 7)
      if (!@@gpio[n] || !@@gpio[n]['path'])
        @@gpio[n] = {'path' => gpioFile}

        if File.exist? gpioFile
          writeTextFile("/sys/class/gpio/gpio#{n}/direction", direction)
        else
          begin
            writeTextFile("/sys/class/gpio/export", n.to_s)
            writeTextFile("/sys/class/gpio/gpio#{n}/direction", direction)
          rescue => ex2
            pmerr = "Unable to export gpio-#{n}: #{ex2}"
            STDERR.puts pmerr
            gpioUsers = readTextFile("/sys/kernel/debug/gpio").split("\n")
            gpioUsers.each do |x|
              y = x.match(/gpio-(\d+)\s+\((\S+)\s*\)/)
              if (y && y[1].to_i == n)
                pmerr2 = "gpio-#{n} consumed by #{y[2]}"
                pmerr += "\n" + pmerr2
                STDERR.puts pmerr
              end
            end
            @@gpio[n] = {}
            block({'value' => false, 'err' => pmerr}) if block
            return false
          end
        end
      end
    else
      @@gpio[n] = {}
    end

    block({'value' => true}) if block
    return true
  end


  def getGpioFile (pin)
    pin = getpin(pin)
    "/sys/class/gpio/gpio#{pin['gpio']}/value"
  end


  def digitalWrite (pin, value, &block)
    pin = getpin(pin)
    value = (value == 0) ? 0 : 1
    gpioFile = getGpioFile(pin)
    led = pin['led']
    if led
      pathA = "/sys/class/leds/beaglebone:"
      pathB = pathA
      pathA += ":#{led}/brightness"
      pathB += "green:#{led}/brightness"
      if File.exist? pathA
        gpioFile = pathA
      elsif File.exist? pathB
        gpioFile = pathB
      else
        STDERR.puts "Unable to find LED: #{led}"
      end
    end
    begin
      writeTextFile(gpioFile, value.to_s)
    rescue => ex
      if block
        block(ex)
      else
        STDERR.puts "Unable to write to #{gpioFile}"
        raise
      end
    end
    return true
  end


  def digitalRead (pin, &block)
    pin = getpin(pin)
    gpioFile = getGpioFile(pin)
    value = readTextFile(gpioFile).to_i
    block(value) if block
    return value
  end


  def analogRead (pin, &block)
    pin = getpin(pin)
    unless @@ainPrefix
      if load_dt('cape-bone-iio')
        ocp = file_find('sys/devices', 'ocp.', 1000)
        helper = file_find(ocp, 'helper.', 10000)
        @@ainPrefix = helper + '/AIN'
        @@indexOffset = 0
        @@scale = 1800
      else
        @@ainPrefix = '/sys/bus/platform/devices/tsc/ain'
        @@indexOffset = 1
        @@scale = 4096
      end
    end
    ainFile = "#{@@ainPrefix}#{pin['ain']+indexOffset}"
    begin
      data = readTextFile(ainFile)
      if /^[-+0-9.]/ =~ data
        data = data.to_f / @@scale
      else
        raise "analogRead(#{pin['key']}) returned #{data}"
      end
      block(data) if block
      data
    rescue => ex
      @@ainPrefix = nil
      STDERR.puts "analogRead error: #{ex}"
      raise
    end
  end


  def shiftOut (dataPin, clockPin, bitOrder, val)
    dataPin = getpin(dataPin)
    clockPin = getpin(clockPin)
    8.times do |i|
      if bitOrder == LSBFIRST
        bit = val & (1 << i)
      else
        bit = val & (1 << (7 - i))
      end
      digitalWrite(dataPin, bit)
      digitalWrite(clockPin, HIGH)
      digitalWrite(clockPin, LOW)
    end
  end


  def analogWrite (pin, value, freq = 2000.0)
    pin = getpin(pin)
    unless pin['pwm']
      raise "#{pin['key']} does not support analogWrite()"
    end

    pwmName = pin['pwm']['name']
    if @@pwm[pwmName] && @@pwm[pwmName]['key'] != pin['key']
      raise "#{pin['key']} requires pwm #{pwmName} but it is already in use by #{@@pwm[pwmName]['key']}"
    end

    unless @@pwm[pwmName]
      @@pwm[pwmName] = {'key' => pin['key']}
      fragment = "bone_pwm_#{pin['key']}"
      if load_dt('am33xx_pwm') && load_dt(fragment)
        ocp = file_find('/sys/devices', 'ocp.')
        pwm_test = file_find(ocp, "pwm_test_#{pin['key']}.", 10000)
        file_find(pwm_test, 'period', 10000)
        @@pwm[pwmName]['pwm_test_path'] = pwm_test
        @@pwm[pwmName]['freq'] = 0
        writeTextFile("#{pwm_test}/polarity", '0')
      else
        @@pwm[pwmName]['old_pwm_path'] = "/sys/class/pwm/#{pin['pwm']['path']}"
        pinMode(pin, OUTPUT, pin['pwm']['muxmode'], 'disabled', 'fast')
        writeTextFile("#{path}/request", '0')
        writeTextFile("#{path}/request", '1')
        writeTextFile("#{path}/period_freq", "#{freq.round}")
        writeTextFile("#{path}/polarity", '0')
        writeTextFile("#{path}/run", '1')
        @@pwm[pwmName]['freq'] = freq
      end
      @@pwm[pwmName]['key'] = pin['key']
    end

    if @@pwm[pwmName]['pwm_test_path'].class == String
      period = (1.0e9 / freq).round
      if @@pwm[pwmName]['freq'] != freq
        writeTextFile("#{@@pwm[pwmName]['pwm_test_path']}/period", "#{period}")
        @@pwm[pwmName]['freq'] = freq
      end
      duty = (period * value).round
      writeTextFile("#{@@pwm[pwmName]['pwm_test_path']}/duty", "#{duty}")
    else
      opp = @@pwm[pwmName]['old_pwm_path']
      if @@pwm[pwmName]['freq'] != freq
        writeTextFile(opp+'/run', '0')
        writeTextFile(opp+'/duty_percent', '0')
        writeTextFile(opp+'/period_freq', "#{freq.round}")
        writeTextFile(opp+'/run', '1')
        @@pwm[pwmName]['freq'] = freq
      end
      writeTextFile(opp+'/duty_percent', "#{(value*100).round}")
    end

    true
  end


  def getPlatform
    platform = { 'name' => 'BeagleBone' }
    if File.exist?( is_capemgr() + '/baseboard/board-name')
      name = readTextFile("#{@@capemgr}/baseboard/board-name").strip
      case name
      when 'A335BONE'
        name = 'BeagleBone'
      when 'A335BNLT'
        name = 'BeagleBone Black'
      end
      platform['name'] = name
      rev = readTextFile("#{@@capemgr}/baseboard/revision").strip
      platform['revision'] = rev if rev.match(/^[\040-\176]*$/)
      ser = readTextFile("#{@@capemgr}/baseboard/serial-number").strip
      platform['serialNumber'] = ser if ser.match(/^[\040-\176]*$/)
    end
    platform
  end

    
end
 
