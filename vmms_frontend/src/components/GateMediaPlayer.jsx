import { useState, useEffect, useMemo } from "react"
import { getMediaFiles } from "../api/media.api"

const fallbackPlaylist = [
  { type: "video", src: "/media/safety1.mp4" },
  { type: "video", src: "/media/company_intro.mp4" },
  { type: "image", src: "/media/ppe_rules.jpg" },
  { type: "image", src: "/media/visitor_rules.jpg" }
]

export default function GateMediaPlayer() {

  const [playlist, setPlaylist] = useState(fallbackPlaylist)
  const [index, setIndex] = useState(0)
  const [fade, setFade] = useState(true)

  const fileBase = useMemo(() => {
    const baseEnv =
      import.meta.env.VITE_FILE_BASE_URL ||
      (import.meta.env.VITE_API_BASE_URL
        ? import.meta.env.VITE_API_BASE_URL.replace(/\/api\/?$/, "")
        : "")
    return baseEnv?.replace(/\/$/, "")
  }, [])

  const resolveSrc = (src) => {
    if (!src) return null
    if (/^(https?:)?\/\//i.test(src) || src.startsWith("data:")) return src
    if (fileBase) return `${fileBase}/${src.replace(/^\//, "")}`
    return `/${src.replace(/^\//, "")}`
  }

  const normalizeMedia = (item) => {
    const rawSrc =
      item?.url ||
      item?.file_url ||
      item?.path ||
      item?.location ||
      item?.src ||
      item?.uri

    const src = resolveSrc(rawSrc)
    if (!src) return null

    const mime = item?.mime_type || item?.content_type || item?.type || ""

    const isVideo =
      mime.startsWith("video") || /\.(mp4|webm|mov|m4v)$/i.test(src)

    return { type: isVideo ? "video" : "image", src }
  }

  const loadMedia = async () => {
    try {
      const res = await getMediaFiles()

      const files =
        res?.data?.media ||
        res?.data?.files ||
        res?.data?.data ||
        []

      const normalized = files.map(normalizeMedia).filter(Boolean)

      if (normalized.length) {
        setPlaylist(normalized)
        setIndex(0)
      }

    } catch (err) {
      console.error("Failed to load media playlist", err)
    }
  }

  useEffect(() => {
    loadMedia()
  }, [])

  useEffect(() => {

    if (!playlist.length) return

    const timer = setInterval(() => {

      setFade(false)

      setTimeout(() => {
        setIndex(prev => (prev + 1) % playlist.length)
        setFade(true)
      }, 400)

    }, 8000)

    return () => clearInterval(timer)

  }, [playlist])

  if (!playlist.length) return null

  const safeIndex = index % playlist.length
  const item = playlist[safeIndex] || fallbackPlaylist[0]

  return (

    <div
      style={{
        width: "100%",
        height: "100%",
        position: "relative",
        overflow: "hidden",
        borderRadius: 8
      }}
    >

      <div
        style={{
          width: "100%",
          height: "100%",
          opacity: fade ? 1 : 0,
          transition: "opacity 0.8s ease-in-out"
        }}
      >

        {item.type === "video" ? (

          <video
            key={item.src}
            src={item.src}
            autoPlay
            muted
            loop
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover"
            }}
          />

        ) : (

          <img
            key={item.src}
            src={item.src}
            alt="Gate media"
            style={{
              width: "100%",
              height: "100%",
              objectFit: "cover"
            }}
          />

        )}

      </div>

    </div>
  )
}