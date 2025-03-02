import { parseImg2WebpArgs } from './parse-command-args'

export function runImg2Webp(module, main, ...args) {
  module[main || '_main'](...parseImg2WebpArgs(module, args))
}
