import { application } from "./application"
import HelloController from "./hello_controller"
import ClipboardController from "./clipboard_controller"
import AiAnalysisController from "./ai_analysis_controller"
application.register("hello", HelloController)
application.register("clipboard", ClipboardController)
application.register("ai-analysis", AiAnalysisController)
