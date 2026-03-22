import { useEffect, useRef } from "react";

export default function useAutoScroll(ref, deps) {
  const isPausedRef = useRef(false);
  const rafRef = useRef(null);
  const lastTsRef = useRef(0);
  const timeoutRef = useRef(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    // 🔴 Pause whenever deps change
    isPausedRef.current = true;

    if (timeoutRef.current) clearTimeout(timeoutRef.current);

    timeoutRef.current = setTimeout(() => {
      isPausedRef.current = false;
    }, 10000); // 10 sec pause

    const step = (ts) => {
      if (!el) return;

      if (!isPausedRef.current && ts - lastTsRef.current > 30) {
        if (el.scrollHeight > el.clientHeight) {
          el.scrollTop += 1;

          // loop scroll
          if (el.scrollTop + el.clientHeight >= el.scrollHeight - 2) {
            el.scrollTop = 0;
          }
        }

        lastTsRef.current = ts;
      }

      rafRef.current = requestAnimationFrame(step);
    };

    rafRef.current = requestAnimationFrame(step);

    return () => {
      if (rafRef.current) cancelAnimationFrame(rafRef.current);
      if (timeoutRef.current) clearTimeout(timeoutRef.current);
    };
  }, deps);
}