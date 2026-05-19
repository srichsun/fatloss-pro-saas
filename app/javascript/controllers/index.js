import { application } from "./application"
import HelloController from "./hello_controller"
import ClipboardController from "./clipboard_controller"
application.register("hello", HelloController)
application.register("clipboard", ClipboardController)
