## route.nim -- Language -> model/system-prompt mapping.
{.experimental: "strict_funcs".}
import std/tables
import detect

type
  ModelConfig* = object
    model_path*: string
    system_prompt*: string

  RouteConfig* = object
    routes*: Table[string, ModelConfig]  ## language code -> config
    default_config*: ModelConfig

  RouteResult* = object
    config*: ModelConfig
    language*: Language
    fallback*: bool

proc new_route_config*(default_model: string, default_prompt: string): RouteConfig =
  RouteConfig(default_config: ModelConfig(model_path: default_model,
                                          system_prompt: default_prompt))

proc add_route*(rc: var RouteConfig, lang_code: string, model: string, prompt: string) =
  rc.routes[lang_code] = ModelConfig(model_path: model, system_prompt: prompt)

proc route*(lang: Language, config: RouteConfig): RouteResult =
  if lang.code in config.routes:
    RouteResult(config: config.routes[lang.code], language: lang, fallback: false)
  else:
    RouteResult(config: config.default_config, language: lang, fallback: true)
