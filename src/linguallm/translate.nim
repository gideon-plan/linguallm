## translate.nim -- Optional pre/post translation layer.
{.experimental: "strict_funcs".}
import basis/code/choice, detect

type
  TranslateFn* = proc(text: string, from_lang, to_lang: string): Choice[string] {.raises: [].}

  TranslateLayer* = object
    translate_fn*: TranslateFn
    model_language*: string  ## Language the model expects (e.g. "en")

proc new_translate_layer*(fn: TranslateFn, model_lang: string = "en"): TranslateLayer =
  TranslateLayer(translate_fn: fn, model_language: model_lang)

proc pre_translate*(layer: TranslateLayer, text: string,
                    input_lang: Language): Choice[string] =
  if input_lang.code == layer.model_language:
    good(text)
  else:
    layer.translate_fn(text, input_lang.code, layer.model_language)

proc post_translate*(layer: TranslateLayer, text: string,
                     target_lang: Language): Choice[string] =
  if target_lang.code == layer.model_language:
    good(text)
  else:
    layer.translate_fn(text, layer.model_language, target_lang.code)
