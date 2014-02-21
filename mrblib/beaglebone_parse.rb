#
# modified from parse.js
#



module BeagleBone
  module Parse

    def self.modeFromStatus (pinData, mode = {})
      mode['mux'] = pinData & 0x07
      mode['slew'] = (pinData & 0x40 != 0) ? 'slow' : 'fast'
      mode['rx'] = (pinData & 0x20 != 0) ? 'enabled' : 'disabled'
      pullup = (pinData & 0x18) >> 3
      if pullup <= 2
        mode['pullup'] = ['pulldown', 'disabled', 'pullup'][pullup]
      else
        raise "Unknown pullup value: #{pullup}"
      end
      mode
    end

    def self.modeFromOmapMux (readout, mode = {})
      breakdown = readout.split("\n")
      mode['mux'] = breakdown[1].split('|')[1].slice(-1)
      pinData = breakdown[0].split('=')[1].slice(1,6).hex
      mode = modeFromStatus(pinData, mode)
      mode['options'] = breakdown[2].split('|').map do |opt|
        opt.gsub(/ /, '').sub('signals:', '')
      end
      mode
    end

    def self.modeFromPinctrl (pins, muxRegOffset, muxBase = 0x44e10800, mode = {})
      return mode unless muxRegOffset
      pinLines = pins.split("\n")
      numRegistered = pinLines[0].sub(/registered pins: (\d+)/, '\1').to_i
      pattern = %r{pin ([0-9]+) .([0-9a-f]+). ([0-9a-f]+) pinctrl-single}
      muxAddress = muxBase + muxRegOffset
      numRegistered.times do |i|
        parsedFields = pattern.match(pinLines[i+1])
        index = parsedFields[1].to_i
        address = parsedFields[2].hex
        status = parsedFields[3].hex
        if address == muxAddress
          mode = modeFromStatus(status, mode)
          return mode
        end
      end
      mode
    end

  end
end

# p BeagleBone::Parse::modeFromOmapMux <<EOD
# name: mcasp0_axr0.spi1_d1 (0x44e10998/0x998 = 0x0023), b NA, t NA
# mode: OMAP_PIN_OUTPUT | OMAP_MUX_MODE3
# signals: mcasp0_axr0 | ehrpwm0_tripzone | NA | spi1_d1 | mmc2_sdcd_mux1 | NA | NA | gpio3_16
# EOD
# {"mux"=>3, "slew"=>"fast", "rx"=>"enabled", "pullup"=>"pulldown", "options"=>["mcasp0_axr0", "ehrpwm0_tripzone", "NA", "spi1_d1", "mmc2_sdcd_mux1", "NA", "NA", "gpio3_16"]}


# x = <<EOD
# registered pins: 2
# pin 108 (44e109b0) 00000027 pinctrl-single
# pin 111 (44e109b1) 00000073 pinctrl-single
# EOD
# p BeagleBone::Parse::modeFromPinctrl x, 0x1b0
# {"mux"=>7, "slew"=>"fast", "rx"=>"enabled", "pullup"=>"pulldown"}
# p BeagleBone::Parse::modeFromPinctrl x, 0x1b1
# {"mux"=>3, "slew"=>"slow", "rx"=>"enabled", "pullup"=>"pullup"}

