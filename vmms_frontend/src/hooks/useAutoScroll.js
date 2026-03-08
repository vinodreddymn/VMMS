import { useEffect } from "react"

export default function useAutoScroll(ref, deps) {

  useEffect(() => {

    const el = ref.current
    if (!el) return

    let rafId = null
    let lastTs = 0

    const step = (ts) => {

      if (ts - lastTs > 30) {

        if (el.scrollHeight > el.clientHeight) {

          el.scrollTop += 1

          if (el.scrollTop + el.clientHeight >= el.scrollHeight - 2) {
            el.scrollTop = 0
          }
        }

        lastTs = ts
      }

      rafId = requestAnimationFrame(step)
    }

    rafId = requestAnimationFrame(step)

    return () => {
      if (rafId) cancelAnimationFrame(rafId)
    }

  }, deps)
}