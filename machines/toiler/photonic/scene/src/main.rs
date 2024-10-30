use std::time::Duration;

use anyhow::Result;
use photonic::color::palette::{Hsl, IntoColor, Srgb, rgb::Rgb, FromColor};

use photonic::{Scene, WithWhite, Rgbw, node::map::Map};
use photonic::attr::{AsFixedAttr, FreeAttrDeclExt, Range};
use photonic_effects::attrs::{Button, Fader, Sequence, Switch};
use photonic_effects::easing::{EasingDirection, Easings};
use photonic_effects::nodes::{Alert, Blackout, Brightness, Noise, Overlay, Raindrops, ColorWheel, Select};
use photonic_audio::attr::Power;
use photonic_output_net::wled;

#[tokio::main]
async fn main() -> Result<()> {
    let mut scene = Scene::new();

    let raindrops_purple = scene.node("raindrops-purple", Raindrops {
        rate: 0.3.fixed(),
        decay: (0.96, 0.98).fixed(),
        color: Range(Hsl::new(245.31, 0.5, 0.5),
                     Hsl::new(333.47, 0.7, 0.5)).fixed(),
    })?;

    let raindrops_green = scene.node("raindrops-green", Raindrops {
        rate: 0.3.fixed(),
        decay: (0.96, 0.98).fixed(),
        color: Range(Hsl::new(66.0, 0.5, 0.5),
                     Hsl::new(130.0, 0.7, 0.5)).fixed(),
    })?;

    let raindrops_orange = scene.node("raindrops-orange", Raindrops {
        rate: 0.3.fixed(),
        decay: (0.96, 0.98).fixed(),
        color: Range(Hsl::new(26.0, 0.5, 0.5),
                     Hsl::new(50.0, 0.7, 0.5)).fixed(),
    })?;

    let beatdrops_power = Power::new()
        .with_low_pass_filter(200.0);
    let beatdrops = scene.node("beatdrops", Raindrops {
        rate: beatdrops_power.scale(0.3),
        decay: (2.0, 3.0).fixed(),
        color: Range(Hsl::new(245.31, 0.5, 0.5), Hsl::new(333.47, 0.7, 0.5)).fixed(),
    })?;

    let input_effect = scene.input::<i64>("effect")?;
    let base = scene.node("base", Select::<Rgb, _>::with_value(input_effect.attr(0))
        .with_easing(Easings::Cubic(EasingDirection::InOut).with_speed(Duration::from_secs(3)))
        .with_source(raindrops_purple)
        .with_source(raindrops_green)
        .with_source(raindrops_orange)
        .with_source(beatdrops)
    )?;

    let input_brightness = scene.input::<f32>("brightness")?;
    let brightness = scene.node("brightness", Brightness {
        value: Fader {
            input: input_brightness.attr(0.0),
            easing: Easings::Cubic(EasingDirection::InOut)
                .with_speed(Duration::from_secs(1)),
        },
        source: base,
        range: None,
    })?;

    let output = wled::WledSender {
        mode: Default::default(),
        size: 50,
        target: "192.168.0.29:21324".parse()?,
    };

    let mut scene = scene.run(brightness, output).await?;

    let restore = photonic_interface_restore::Restore {
        path: "/var/lib/photonic/state".into(),
        write_threshold: 5,
        write_timeout: Duration::from_secs(1),
    };
    scene.serve("restore", restore);

    let cli = photonic_interface_cli::telnet::CLI {
        address: "127.0.0.1:8888".parse()?,
    };
   scene.serve("CLI", cli);

    let mqtt = photonic_interface_mqtt::MQTT::with_url("mqtt://127.0.0.1:1883?client_id=photonic")?
        .with_realm("frisch/home/photonic");
   scene.serve("MQTT", mqtt);

   return Ok(scene.run(60).await?);
}
