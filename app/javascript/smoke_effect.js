const SMOKE_COUNT = 9

function buildSmoke() {
  const stage = document.querySelector("[data-smoke-stage]")
  if (!stage || window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

  stage.replaceChildren()

  for (let index = 0; index < SMOKE_COUNT; index += 1) {
    const wisp = document.createElement("span")
    const left = 8 + Math.random() * 84
    const size = 8 + Math.random() * 10
    const drift = (Math.random() * 12 - 6).toFixed(1)
    const duration = 16 + Math.random() * 10
    const delay = -(Math.random() * duration)

    wisp.className = "smoke-wisp"
    wisp.style.left = `${left}%`
    wisp.style.setProperty("--smoke-size", `${size}rem`)
    wisp.style.setProperty("--smoke-drift", `${drift}rem`)
    wisp.style.setProperty("--smoke-duration", `${duration.toFixed(1)}s`)
    wisp.style.setProperty("--smoke-delay", `${delay.toFixed(1)}s`)

    stage.append(wisp)
  }
}

document.addEventListener("turbo:load", buildSmoke)
document.addEventListener("turbo:render", buildSmoke)
