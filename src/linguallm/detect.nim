## detect.nim -- Lingua detection as routing pre-processor.
{.experimental: "strict_funcs".}
import basis/code/choice

type
  Language* = object
    code*: string
    name*: string
    confidence*: float64

  DetectFn* = proc(text: string): Choice[Language] {.raises: [].}

proc language*(code, name: string, confidence: float64 = 1.0): Language =
  Language(code: code, name: name, confidence: confidence)

proc detect*(text: string, detect_fn: DetectFn): Choice[Language] =
  detect_fn(text)
