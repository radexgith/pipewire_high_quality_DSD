alsa = {
    capture = {
        ["period-size"] = 128,
        ["buffer-size"] = 512,
    },
    playback = {
        ["period-size"] = 160,
        ["buffer-size"] = 640,
    },
}

--alsa = {
--    capture = {
--        ["period-size"] = 128,
--        ["buffer-size"] = 640,
--    },
--    playback = {
--        ["period-size"] = 192,
--        ["buffer-size"] = 960,
--    },
--}

alsa_monitor.enabled = true

alsa-monitor.properties = {
  ["api.alsa.period-size"] = 256,
  ["api.alsa.period-num"] = 3,
  ["api.alsa.headroom"] = 0,
  ["api.alsa.disable-mmap"] = false,
  ["api.alsa.disable-batch"] = false,
  ["api.alsa.use-chmap"] = false,
  ["audio.format"] = "S32LE",
  ["audio.rate"] = 192000,
  ["audio.channels"] = 8,
  ["audio.position"] = "FL,FR,FC,LFE,BL,BR,SL,SR"
  -- Create a JACK device. This is not enabled by default because
  -- it requires that the PipeWire JACK replacement libraries are
  -- not used by the session manager, in order to be able to
  -- connect to the real JACK server.
  --["alsa.jack-device"] = false,

  -- Reserve devices via org.freedesktop.ReserveDevice1 on D-Bus
  -- Disable if you are running a system-wide instance, which
  -- doesn't have access to the D-Bus user session
  ["alsa.reserve"] = true,
  --["alsa.reserve.priority"] = -20,
  --["alsa.reserve.application-name"] = "WirePlumber",

  -- Enables MIDI functionality
  ["alsa.midi"] = true,

  -- Enables monitoring of alsa MIDI devices
  ["alsa.midi.monitoring"] = true,

  -- MIDI bridge node properties
  ["alsa.midi.node-properties"] = {
    -- Name set for the node with ALSA MIDI ports
    ["node.name"] = "Midi-Bridge",
    -- Removes longname/number from MIDI port names
    --["api.alsa.disable-longname"] = true,
    ["priority.session"] = 100,
    ["priority.driver"] = 1,
  },

  -- These properties override node defaults when running in a virtual machine.
  -- The rules below still override those.
  ["vm.node.defaults"] = {
    ["api.alsa.period-size"] = 1024,
    ["api.alsa.headroom"] = 8192,
  },
}

alsa_monitor.rules = {
  -- An array of matches/actions to evaluate.
  --
  -- If you want to disable some devices or nodes, you can apply properties per device as the following example.
  -- The name can be found by running pw-cli ls Device, or pw-cli dump Device
  --{
  --  matches = {
  --    {
  --      { "device.name", "matches", "name_of_some_disabled_card" },
  --    },
  --  },
  --  apply_properties = {
  --    ["device.disabled"] = true,
  --  },
  --}
  {
    -- Rules for matching a device or node. It is an array of
    -- properties that all need to match the regexp. If any of the
    -- matches work, the actions are executed for the object.
    matches = {
      {
        -- This matches all cards.
        { "device.name", "matches", "alsa_card.*" },
      },
    },
    -- Apply properties on the matched object.
    apply_properties = {
      -- Use ALSA-Card-Profile devices. They use UCM or the profile
      -- configuration to configure the device and mixer settings.
      ["api.alsa.use-acp"] = true,

      -- Use UCM instead of profile when available. Can be
      -- disabled to skip trying to use the UCM profile.
      --["api.alsa.use-ucm"] = true,

      -- Don't use the hardware mixer for volume control. It
      -- will only use software volume. The mixer is still used
      -- to mute unused paths based on the selected port.
      --["api.alsa.soft-mixer"] = false,

      -- Ignore decibel settings of the driver. Can be used to
      -- work around buggy drivers that report wrong values.
      --["api.alsa.ignore-dB"] = false,

      -- The profile set to use for the device. Usually this is
      -- "default.conf" but can be changed with a udev rule or here.
      --["device.profile-set"] = "profileset-name",

      -- The default active profile. Is by default set to "Off".
      --["device.profile"] = "default profile name",

      -- Automatically select the best profile. This is the
      -- highest priority available profile. This is disabled
      -- here and instead implemented in the session manager
      -- where it can save and load previous preferences.
      ["api.acp.auto-profile"] = false,

      -- Automatically switch to the highest priority available port.
      -- This is disabled here and implemented in the session manager instead.
      ["api.acp.auto-port"] = false,

      -- Other properties can be set here.
      --["device.nick"] = "My Device",
    },
  },
  {
    matches = {
      {
        -- Matches all sources.
        { "node.name", "matches", "alsa_input.*" },
      },
      {
        -- Matches all sinks.
        { "node.name", "matches", "alsa_output.*" },
      },
    },
    apply_properties = {
      ["node.nick"]              = "High Quality Node",
      ["node.description"]       = "Node for High Quality Audio",
      ["priority.driver"]        = 100,
      ["priority.session"]       = 100,
      ["node.pause-on-idle"]     = false,
      ["monitor.channel-volumes"] = false,
      ["resample.quality"]       = 10,       -- Höchste Qualität für Resampling
      ["resample.disable"]       = false,
      ["channelmix.normalize"]   = false,
      ["channelmix.mix-lfe"]     = true,
      ["channelmix.upmix"]       = true,
      ["channelmix.upmix-method"] = "psd",   -- Kann auch "none" oder "simple" sein, je nach Bedarf
      ["channelmix.lfe-cutoff"]  = 150,
      ["channelmix.fc-cutoff"]   = 12000,
      ["channelmix.rear-delay"]  = 12.0,
      ["channelmix.stereo-widen"] = 0.0,
      ["channelmix.hilbert-taps"] = 0,
      ["channelmix.disable"]     = false,
      ["dither.noise"]           = 0,
      ["dither.method"]          = "shaped5",  -- Für hochwertige Dithering
      ["audio.channels"]         = 8,
      ["audio.format"]           = "S32LE",    -- Höhere Bit-Tiefe für bessere Qualität
      ["audio.rate"]             = 192000,      -- Höhere Abtastrate für bessere Qualität
      ["audio.allowed-rates"]    = "48000,96000,192000",
      ["audio.position"]         = "FL,FR,FC,LFE,BL,BR,SL,SR",
      ["api.alsa.period-size"]   = 256,     -- Kleinere Period-Größe für geringere Latenz
      ["api.alsa.period-num"]    = 2,
      ["api.alsa.headroom"]      = 0,
      ["api.alsa.start-delay"]   = 0,
      ["api.alsa.disable-mmap"]  = false,
      ["api.alsa.disable-batch"] = false,
      ["api.alsa.use-chmap"]     = false,
      ["api.alsa.multirate"]     = true,
      ["latency.internal.rate"]  = 0,
      ["latency.internal.ns"]    = 500000,  -- 1 ms Latenz
      ["clock.name"]             = "api.alsa.0",
      ["session.suspend-timeout-seconds"] = 0,  -- 0 disables suspend

    },
  },
}
