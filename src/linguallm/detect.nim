## detect.nim -- Lingua detection as routing pre-processor.
{.experimental: "strict_funcs".}
import lattice

type
  Language* = object
    code*: string
    name*: string
    confidence*: float64

  DetectFn* = proc(text: string): Result[Language, BridgeError] {.raises: [].}

proc language*(code, name: string, confidence: float64 = 1.0): Language =
  Language(code: code, name: name, confidence: confidence)

proc detect*(text: string, detect_fn: DetectFn): Result[Language, BridgeError] =
  detect_fn(text)
