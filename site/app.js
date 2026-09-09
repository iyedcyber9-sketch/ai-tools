(function(){
  'use strict';

  // ===== EMBEDDED TRANSLATIONS =====
  var T = {
  "en": {
    "nav_download": "Download","nav_features": "Features","nav_community": "Community",
    "hero_title": "Free Offline AI for Everyone","hero_sub": "DeepSeek & Qwen models running locally on your device. No API keys needed.",
    "stat_models": "Models","stat_platforms": "Platforms","stat_downloads": "Downloads",
    "btn_download_now": "Download Now",
    "feat_title": "Why AI Tools?","feat1_title": "100% Private","feat1_desc": "All inference happens locally. Your conversations never leave your device.",
    "feat2_title": "Multi-Platform","feat2_desc": "Windows, Linux, Android — same features everywhere.",
    "feat3_title": "GPU Accelerated","feat3_desc": "Auto-detects NVIDIA CUDA, Vulkan, OpenCL.",
    "feat4_title": "PDF Q&A","feat4_desc": "Upload PDFs and ask questions. AI answers using RAG.",
    "dl_title": "Download AI Tools","dl_sub": "Free forever. No account needed.",
    "dl_windows": "Windows","dl_windows_desc": "Windows 10/11 64-bit",
    "dl_linux": "Linux","dl_linux_desc": "Kali / Ubuntu / Debian x64",
    "dl_android": "Android","dl_android_desc": "Android 7+ arm64",
    "dl_btn_exe": "Download .exe","dl_btn_tar": "Download .tar.gz","dl_btn_apk": "Download .apk",
    "comm_banner_title": "Community","comm_banner_desc": "Read reviews from other users or report bugs to help us improve AI Tools.",
    "comm_banner_btn": "View Community →",
    "footer_copy": "\u00a9 2026 AI Tools. MIT License.","footer_github": "GitHub","footer_download": "Download","footer_community": "Community",
    "comm_hero_title": "Community","comm_hero_desc": "Reviews, feedback, and bug reports from AI Tools users.",
    "comm_back": "\u2190 Back to Download",
    "comm_tab_reviews": "Reviews","comm_tab_bugs": "Bug Reports","comm_tab_write": "Write a Review",
    "comm_reviews_title": "User Reviews","comm_reviews_count": "reviews","comm_avg": "Avg:","comm_stars": "Stars",
    "comm_filter_all": "All","comm_filter_5": "5 Stars","comm_filter_4": "4 Stars","comm_filter_3": "3 Stars","comm_filter_low": "1-2 Stars",
    "comm_bugs_title": "Bug Reports","comm_bugs_count": "reports","comm_bugs_open": "open",
    "comm_filter_critical": "Critical","comm_filter_high": "High","comm_filter_medium": "Medium","comm_filter_low_sev": "Low",
    "comm_write_review": "Share Your Experience",
    "comm_name": "Name","comm_name_ph": "Your name","comm_platform": "Platform","comm_rating": "Rating",
    "comm_review_label": "Your Review","comm_review_ph": "What do you think about AI Tools?","comm_submit_review": "Submit Review",
    "comm_report_bug": "Report a Bug","comm_version": "App Version","comm_version_ph": "v1.0.1",
    "comm_severity": "Severity","comm_sev_low": "Low","comm_sev_medium": "Medium","comm_sev_high": "High","comm_sev_critical": "Critical",
    "comm_bug_title": "Bug Title","comm_bug_title_ph": "Brief summary",
    "comm_bug_happened": "What happened?","comm_bug_happened_ph": "Describe the bug...",
    "comm_bug_steps": "Steps to Reproduce (optional)","comm_bug_steps_ph": "1. Open app\n2. Go to...\n3. Click...",
    "comm_submit_bug": "Submit Bug Report",
    "comm_empty_reviews": "No reviews yet. Be the first!","comm_empty_bugs": "No bug reports. Looking good!",
    "comm_steps_label": "Steps to reproduce"
  },
  "ar": {
    "nav_download": "\u062a\u062d\u0645\u064a\u0644","nav_features": "\u0627\u0644\u0645\u064a\u0632\u0627\u062a","nav_community": "\u0627\u0644\u0645\u062c\u062a\u0645\u0639",
    "hero_title": "\u0630\u0643\u0627\u0621 \u0627\u0635\u0637\u0646\u0627\u0639\u064a \u0645\u062c\u0627\u0646\u064a \u0628\u062f\u0648\u0646 \u0625\u0646\u062a\u0631\u0646\u062a \u0644\u0644\u062c\u0645\u064a\u0639",
    "hero_sub": "\u0646\u0645\u0627\u0630\u062c DeepSeek \u0648 Qwen \u062a\u0639\u0645\u0644 \u0645\u062d\u0644\u064a\u0627\u064b \u0639\u0644\u0649 \u062c\u0647\u0627\u0632\u0643. \u0644\u0627 \u062d\u0627\u062c\u0629 \u0644\u0645\u0641\u0627\u062a\u064a\u062d API.",
    "stat_models": "\u0646\u0645\u0627\u0630\u062c","stat_platforms": "\u0645\u0646\u0635\u0627\u062a","stat_downloads": "\u062a\u062d\u0645\u064a\u0644\u0627\u062a",
    "btn_download_now": "\u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0622\u0646",
    "feat_title": "\u0644\u0645\u0627\u0630\u0627 AI Tools?","feat1_title": "\u062e\u0635\u0648\u0635\u064a\u0629 100%","feat1_desc": "\u0643\u0644 \u0627\u0644\u0645\u0639\u0627\u0644\u062c\u0629 \u062a\u062d\u062f\u062b \u0645\u062d\u0644\u064a\u0627\u064b. \u0645\u062d\u0627\u062f\u062b\u0627\u062a\u0643 \u0644\u0627 \u062a\u063a\u0631\u062f \u062c\u0647\u0627\u0632\u0643.",
    "feat2_title": "\u0645\u062a\u0639\u062f\u062f \u0627\u0644\u0645\u0646\u0635\u0627\u062a","feat2_desc": "\u0648\u064a\u0646\u062f\u0648\u0632\u060c \u0644\u064a\u0646\u0643\u0633\u060c \u0623\u0646\u062f\u0631\u0648\u064a\u062f \u2014 \u0646\u0641\u0633 \u0627\u0644\u0645\u064a\u0632\u0627\u062a \u0641\u064a \u0643\u0644 \u0645\u0643\u0627\u0646.",
    "feat3_title": "\u062a\u0633\u0631\u064a\u0639 \u0628\u0627\u0644\u06af\u0648","feat3_desc": "\u0643\u0634\u0641 \u062a\u0644\u0642\u0627\u0626\u064a NVIDIA CUDA \u0648 Vulkan \u0648 OpenCL.",
    "feat4_title": "\u0623\u0633\u0626\u0644\u0629 \u0648 \u0623\u062c\u0648\u0628\u0629 \u0639\u0646 PDF","feat4_desc": "\u0627\u0631\u0641\u0639 \u0645\u0644\u0641\u0627\u062a PDF \u0648\u0627\u0633\u0623\u0644 \u0623\u0633\u0626\u0644\u0629. \u0627\u0644\u0630\u0643\u0627\u0621 \u0627\u0644\u0627\u0635\u0637\u0646\u0627\u0639\u064a \u064a\u062c\u064a\u0628 \u0628\u0627\u0633\u062a\u062e\u062f\u0627\u0645 RAG.",
    "dl_title": "\u062a\u062d\u0645\u064a\u0644 AI Tools","dl_sub": "\u0645\u062c\u0627\u0646\u064a \u0644\u0644\u0623\u0628\u062f. \u0644\u0627 \u062d\u0627\u062c\u0629 \u0644\u062d\u0633\u0627\u0628.",
    "dl_windows": "\u0648\u064a\u0646\u062f\u0648\u0632","dl_windows_desc": "\u0648\u064a\u0646\u062f\u0648\u0632 10/11 64 \u0628\u062a",
    "dl_linux": "\u0644\u064a\u0646\u0643\u0633","dl_linux_desc": "\u0643\u0627\u0644\u064a / \u0623\u0648\u0628\u0648\u0646\u062a\u0648 / \u062f\u0628\u064a\u0627\u0646 64 \u0628\u062a",
    "dl_android": "\u0623\u0646\u062f\u0631\u0648\u064a\u062f","dl_android_desc": "\u0623\u0646\u062f\u0631\u0648\u064a\u062f 7+ arm64",
    "dl_btn_exe": "\u062a\u062d\u0645\u064a\u0644 .exe","dl_btn_tar": "\u062a\u062d\u0645\u064a\u0644 .tar.gz","dl_btn_apk": "\u062a\u062d\u0645\u064a\u0644 .apk",
    "comm_banner_title": "\u0627\u0644\u0645\u062c\u062a\u0645\u0639","comm_banner_desc": "\u0627\u0642\u0631\u0623 \u0645\u0631\u0627\u062c\u0639\u0627\u062a \u0627\u0644\u0645\u0633\u062a\u062e\u062f\u0645\u064a\u0646 \u0623\u0648 \u0623\u063a\u0644\u0628 \u0639\u0646 \u0623\u062e\u0637\u0627\u0621 \u0644\u0645\u0633\u0627\u0639\u062f\u062a\u0646\u0627 \u0641\u064a \u062a\u062d\u0633\u064a\u0646 AI Tools.",
    "comm_banner_btn": "\u0639\u0631\u0636 \u0627\u0644\u0645\u062c\u062a\u0645\u0639 \u2190",
    "footer_copy": "\u00a9 2026 AI Tools. \u0631\u062e\u0635\u0629 MIT.","footer_github": "GitHub","footer_download": "\u062a\u062d\u0645\u064a\u0644","footer_community": "\u0627\u0644\u0645\u062c\u062a\u0645\u0639",
    "comm_hero_title": "\u0627\u0644\u0645\u062c\u062a\u0645\u0639","comm_hero_desc": "\u0645\u0631\u0627\u062c\u0639\u0627\u062a \u0648\u062a\u0642\u0627\u0631\u064a\u0631 \u0623\u062e\u0637\u0627\u0621 \u0645\u0646 \u0645\u0633\u062a\u062e\u062f\u0645\u064a AI Tools.",
    "comm_back": "\u2190 \u0627\u0644\u0639\u0648\u062f\u0629 \u0644\u0644\u062a\u062d\u0645\u064a\u0644",
    "comm_tab_reviews": "\u0627\u0644\u0645\u0631\u0627\u062c\u0639\u0627\u062a","comm_tab_bugs": "\u062a\u0642\u0627\u0631\u064a\u0631 \u0627\u0644\u0623\u062e\u0637\u0627\u0621","comm_tab_write": "\u0627\u0643\u062a\u0628 \u0645\u0631\u0627\u062c\u0639\u0629",
    "comm_reviews_title": "\u0645\u0631\u0627\u062c\u0639\u0627\u062a \u0627\u0644\u0645\u0633\u062a\u062e\u062f\u0645\u064a\u0646","comm_reviews_count": "\u0645\u0631\u0627\u062c\u0639\u0627\u062a","comm_avg": "\u0627\u0644\u0645\u062a\u0648\u0633\u0637:","comm_stars": "\u0646\u062c\u0648\u0645",
    "comm_filter_all": "\u0627\u0644\u0643\u0644","comm_filter_5": "5 \u0646\u062c\u0648\u0645","comm_filter_4": "4 \u0646\u062c\u0648\u0645","comm_filter_3": "3 \u0646\u062c\u0648\u0645","comm_filter_low": "1-2 \u0646\u062c\u0648\u0645",
    "comm_bugs_title": "\u062a\u0642\u0627\u0631\u064a\u0631 \u0627\u0644\u0623\u062e\u0637\u0627\u0621","comm_bugs_count": "\u062a\u0642\u0627\u0631\u064a\u0631","comm_bugs_open": "\u0645\u0641\u062a\u0648\u062d\u0629",
    "comm_filter_critical": "\u062d\u0631\u062c","comm_filter_high": "\u0639\u0627\u0644\u064a","comm_filter_medium": "\u0645\u062a\u0648\u0633\u0637","comm_filter_low_sev": "\u0645\u0646\u062e\u0641\u0636",
    "comm_write_review": "\u0634\u0627\u0631\u0643 \u062a\u062c\u0631\u0628\u062a\u0643",
    "comm_name": "\u0627\u0644\u0627\u0633\u0645","comm_name_ph": "\u0627\u0633\u0645\u0643","comm_platform": "\u0627\u0644\u0645\u0646\u0635\u0629","comm_rating": "\u0627\u0644\u062a\u0642\u064a\u064a\u0645",
    "comm_review_label": "\u0645\u0631\u0627\u062c\u0639\u062a\u0643","comm_review_ph": "\u0645\u0627\u0630\u0627 \u062a\u0641\u063a\u0644 \u0641\u064a AI Tools?","comm_submit_review": "\u0625\u0631\u0633\u0627\u0644 \u0627\u0644\u0645\u0631\u0627\u062c\u0639\u0629",
    "comm_report_bug": "\u0627\u0644\u0625\u0628\u0644\u0627\u063a \u0639\u0646 \u062e\u0637\u0623","comm_version": "\u0625\u0635\u062f\u0627\u0631 \u0627\u0644\u062a\u0637\u0628\u064a\u0642","comm_version_ph": "v1.0.1",
    "comm_severity": "\u0627\u0644\u062e\u0637\u0648\u0631\u0629","comm_sev_low": "\u0645\u0646\u062e\u0641\u0636","comm_sev_medium": "\u0645\u062a\u0648\u0633\u0637","comm_sev_high": "\u0639\u0627\u0644\u064a","comm_sev_critical": "\u062d\u0631\u062c",
    "comm_bug_title": "\u0639\u0646\u0648\u0627\u0646 \u0627\u0644\u062e\u0637\u0623","comm_bug_title_ph": "\u0645\u0644\u062e\u0635 \u0645\u062e\u062a\u0635\u0631",
    "comm_bug_happened": "\u0645\u0627\u0630\u0627 \u062d\u062f\u062b؟","comm_bug_happened_ph": "\u0635\u0641 \u0627\u0644\u062e\u0637\u0623...",
    "comm_bug_steps": "\u062e\u0637\u0648\u0627\u062a \u0627\u0644\u062a\u0643\u0631\u0627\u0631 (\u0627\u062e\u062a\u064a\u0627\u0631\u064a)","comm_bug_steps_ph": "1. \u0627\u0641\u062a\u062d \u0627\u0644\u062a\u0637\u0628\u064a\u0642\n2. \u0627\u0630\u0647\u0628 \u0625\u0644\u0649...\n3. \u0627\u0636\u063a\u0637...",
    "comm_submit_bug": "\u0625\u0631\u0633\u0627\u0644 \u062a\u0642\u0631\u064a\u0631 \u0627\u0644\u062e\u0637\u0623",
    "comm_empty_reviews": "\u0644\u0627 \u062a\u0648\u062c\u062f \u0645\u0631\u0627\u062c\u0639\u0627\u062a \u0628\u0639\u062f. \u0643\u0646 \u0623\u0648\u0644 \u0645\u0646 \u064a\u0634\u0627\u0631\u0643!","comm_empty_bugs": "\u0644\u0627 \u062a\u0648\u062c\u062f \u062a\u0642\u0627\u0631\u064a\u0631 \u0623\u062e\u0637\u0627\u0621. \u064a\u0628\u062f\u0648 \u062c\u064a\u062f\u0627\u064b!",
    "comm_steps_label": "\u062e\u0637\u0648\u0627\u062a \u0627\u0644\u062a\u0643\u0631\u0627\u0631"
  },
  "es": {
    "nav_download": "Descargar","nav_features": "Caracter\u00edsticas","nav_community": "Comunidad",
    "hero_title": "IA Offline Gratis para Todos","hero_sub": "Modelos DeepSeek y Qwen ejecut\u00e1ndose localmente en tu dispositivo. Sin claves API.",
    "stat_models": "Modelos","stat_platforms": "Plataformas","stat_downloads": "Descargas",
    "btn_download_now": "Descargar Ahora",
    "feat_title": "\u00bfPor qu\u00e9 AI Tools?","feat1_title": "100% Privado","feat1_desc": "Toda la inferencia ocurre localmente. Tus conversaciones nunca salen de tu dispositivo.",
    "feat2_title": "Multi-Plataforma","feat2_desc": "Windows, Linux, Android \u2014 las mismas funciones en todas partes.",
    "feat3_title": "Acelerado por GPU","feat3_desc": "Detecta autom\u00e1ticamente NVIDIA CUDA, Vulkan, OpenCL.",
    "feat4_title": "Preguntas y Respuestas PDF","feat4_desc": "Sube PDFs y haz preguntas. La IA responde usando RAG.",
    "dl_title": "Descargar AI Tools","dl_sub": "Gratis para siempre. Sin cuenta necesaria.",
    "dl_windows": "Windows","dl_windows_desc": "Windows 10/11 64-bit",
    "dl_linux": "Linux","dl_linux_desc": "Kali / Ubuntu / Debian x64",
    "dl_android": "Android","dl_android_desc": "Android 7+ arm64",
    "dl_btn_exe": "Descargar .exe","dl_btn_tar": "Descargar .tar.gz","dl_btn_apk": "Descargar .apk",
    "comm_banner_title": "Comunidad","comm_banner_desc": "Lee rese\u00f1as de otros usuarios o reporta errores para ayudarnos a mejorar.",
    "comm_banner_btn": "Ver Comunidad \u2192",
    "footer_copy": "\u00a9 2026 AI Tools. Licencia MIT.","footer_github": "GitHub","footer_download": "Descargar","footer_community": "Comunidad",
    "comm_hero_title": "Comunidad","comm_hero_desc": "Rese\u00f1as y reportes de errores de usuarios de AI Tools.",
    "comm_back": "\u2190 Volver a Descargar",
    "comm_tab_reviews": "Rese\u00f1as","comm_tab_bugs": "Reportes de Errores","comm_tab_write": "Escribir Rese\u00f1a",
    "comm_reviews_title": "Rese\u00f1as de Usuarios","comm_reviews_count": "rese\u00f1as","comm_avg": "Promedio:","comm_stars": "Estrellas",
    "comm_filter_all": "Todas","comm_filter_5": "5 Estrellas","comm_filter_4": "4 Estrellas","comm_filter_3": "3 Estrellas","comm_filter_low": "1-2 Estrellas",
    "comm_bugs_title": "Reportes de Errores","comm_bugs_count": "reportes","comm_bugs_open": "abiertos",
    "comm_filter_critical": "Cr\u00edtico","comm_filter_high": "Alto","comm_filter_medium": "Medio","comm_filter_low_sev": "Bajo",
    "comm_write_review": "Comparte Tu Experiencia",
    "comm_name": "Nombre","comm_name_ph": "Tu nombre","comm_platform": "Plataforma","comm_rating": "Calificaci\u00f3n",
    "comm_review_label": "Tu Rese\u00f1a","comm_review_ph": "\u00bfQu\u00e9 piensas de AI Tools?","comm_submit_review": "Enviar Rese\u00f1a",
    "comm_report_bug": "Reportar un Error","comm_version": "Versi\u00f3n","comm_version_ph": "v1.0.1",
    "comm_severity": "Gravedad","comm_sev_low": "Bajo","comm_sev_medium": "Medio","comm_sev_high": "Alto","comm_sev_critical": "Cr\u00edtico",
    "comm_bug_title": "T\u00edtulo del Error","comm_bug_title_ph": "Resumen breve",
    "comm_bug_happened": "\u00bfQu\u00e9 pas\u00f3?","comm_bug_happened_ph": "Describe el error...",
    "comm_bug_steps": "Pasos para Reproducir (opcional)","comm_bug_steps_ph": "1. Abrir app\n2. Ir a...\n3. Hacer clic...",
    "comm_submit_bug": "Enviar Reporte",
    "comm_empty_reviews": "No hay rese\u00f1as a\u00fan. \u00a1S\u00e9 el primero!","comm_empty_bugs": "\u00a1No hay reportes de errores!",
    "comm_steps_label": "Pasos para reproducir"
  },
  "fr": {
    "nav_download": "T\u00e9l\u00e9charger","nav_features": "Fonctionnalit\u00e9s","nav_community": "Communaut\u00e9",
    "hero_title": "IA Hors Ligne Gratuite pour Tous","hero_sub": "Mod\u00e8les DeepSeek et Qwen ex\u00e9cut\u00e9s localement sur votre appareil. Aucune cl\u00e9 API requise.",
    "stat_models": "Mod\u00e8les","stat_platforms": "Plateformes","stat_downloads": "T\u00e9l\u00e9chargements",
    "btn_download_now": "T\u00e9l\u00e9charger",
    "feat_title": "Pourquoi AI Tools?","feat1_title": "100% Priv\u00e9","feat1_desc": "Toute l'inf\u00e9rence se fait localement. Vos conversations ne quittent jamais votre appareil.",
    "feat2_title": "Multi-Plateforme","feat2_desc": "Windows, Linux, Android \u2014 les m\u00eames fonctionnalit\u00e9s partout.",
    "feat3_title": "Acc\u00e9l\u00e9r\u00e9 par GPU","feat3_desc": "D\u00e9tection automatique de NVIDIA CUDA, Vulkan, OpenCL.",
    "feat4_title": "Questions/R\u00e9ponses PDF","feat4_desc": "T\u00e9l\u00e9chargez des PDF et posez des questions. L'IA r\u00e9pond via RAG.",
    "dl_title": "T\u00e9l\u00e9charger AI Tools","dl_sub": "Gratuit pour toujours. Aucun compte n\u00e9cessaire.",
    "dl_windows": "Windows","dl_windows_desc": "Windows 10/11 64-bit",
    "dl_linux": "Linux","dl_linux_desc": "Kali / Ubuntu / Debian x64",
    "dl_android": "Android","dl_android_desc": "Android 7+ arm64",
    "dl_btn_exe": "T\u00e9l\u00e9charger .exe","dl_btn_tar": "T\u00e9l\u00e9charger .tar.gz","dl_btn_apk": "T\u00e9l\u00e9charger .apk",
    "comm_banner_title": "Communaut\u00e9","comm_banner_desc": "Lisez les avis d'autres utilisateurs ou signalez des bugs pour nous aider \u00e0 am\u00e9liorer.",
    "comm_banner_btn": "Voir la Communaut\u00e9 \u2192",
    "footer_copy": "\u00a9 2026 AI Tools. Licence MIT.","footer_github": "GitHub","footer_download": "T\u00e9l\u00e9charger","footer_community": "Communaut\u00e9",
    "comm_hero_title": "Communaut\u00e9","comm_hero_desc": "Avis et rapports de bugs des utilisateurs d'AI Tools.",
    "comm_back": "\u2190 Retour au T\u00e9l\u00e9chargement",
    "comm_tab_reviews": "Avis","comm_tab_bugs": "Rapports de Bugs","comm_tab_write": "\u00c9crire un Avis",
    "comm_reviews_title": "Avis Utilisateurs","comm_reviews_count": "avis","comm_avg": "Moyenne:","comm_stars": "\u00c9toiles",
    "comm_filter_all": "Tous","comm_filter_5": "5 \u00c9toiles","comm_filter_4": "4 \u00c9toiles","comm_filter_3": "3 \u00c9toiles","comm_filter_low": "1-2 \u00c9toiles",
    "comm_bugs_title": "Rapports de Bugs","comm_bugs_count": "rapports","comm_bugs_open": "ouverts",
    "comm_filter_critical": "Critique","comm_filter_high": "\u00c9lev\u00e9","comm_filter_medium": "Moyen","comm_filter_low_sev": "Faible",
    "comm_write_review": "Partagez Votre Exp\u00e9rience",
    "comm_name": "Nom","comm_name_ph": "Votre nom","comm_platform": "Plateforme","comm_rating": "Note",
    "comm_review_label": "Votre Avis","comm_review_ph": "Que pensez-vous d'AI Tools?","comm_submit_review": "Envoyer l'Avis",
    "comm_report_bug": "Signaler un Bug","comm_version": "Version","comm_version_ph": "v1.0.1",
    "comm_severity": "Gravit\u00e9","comm_sev_low": "Faible","comm_sev_medium": "Moyen","comm_sev_high": "\u00c9lev\u00e9","comm_sev_critical": "Critique",
    "comm_bug_title": "Titre du Bug","comm_bug_title_ph": "R\u00e9sum\u00e9 bref",
    "comm_bug_happened": "Que s'est-il pass\u00e9?","comm_bug_happened_ph": "D\u00e9crivez le bug...",
    "comm_bug_steps": "\u00c9tapes pour Reproduire (optionnel)","comm_bug_steps_ph": "1. Ouvrir l'app\n2. Aller \u00e0...\n3. Cliquer...",
    "comm_submit_bug": "Envoyer le Rapport",
    "comm_empty_reviews": "Aucun avis pour l'instant. Soyez le premier!","comm_empty_bugs": "Aucun rapport de bug. \u00caa a l'air bien!",
    "comm_steps_label": "\u00c9tapes pour reproduire"
  }
  };

  // ===== THEME =====
  var savedTheme = localStorage.getItem('theme') || 'dark';
  document.documentElement.setAttribute('data-theme', savedTheme);

  window.toggleTheme = function(){
    var cur = document.documentElement.getAttribute('data-theme');
    var next = cur === 'dark' ? 'light' : 'dark';
    document.documentElement.setAttribute('data-theme', next);
    localStorage.setItem('theme', next);
    var icon = document.getElementById('theme-icon');
    if(icon) icon.textContent = next === 'dark' ? '\ud83c\udf19' : '\u2600\ufe0f';
  };

  // ===== LANGUAGE =====
  var currentLang = localStorage.getItem('lang') || 'en';

  function applyLang(lang) {
    currentLang = lang;
    localStorage.setItem('lang', lang);
    document.documentElement.setAttribute('dir', lang === 'ar' ? 'rtl' : 'ltr');
    document.documentElement.setAttribute('lang', lang);
    var t = T[lang]; if (!t) return;
    document.querySelectorAll('[data-i18n]').forEach(function(el) {
      var key = el.getAttribute('data-i18n');
      if (t[key]) el.textContent = t[key];
    });
    document.querySelectorAll('[data-i18n-ph]').forEach(function(el) {
      var key = el.getAttribute('data-i18n-ph');
      if (t[key]) el.setAttribute('placeholder', t[key]);
    });
    var lbl = document.getElementById('lang-label');
    if(lbl) lbl.textContent = lang.toUpperCase();
  }

  window.toggleLangMenu = function() {
    var m = document.getElementById('lang-menu');
    if(m) m.classList.toggle('show');
  };

  window.setLang = function(lang) {
    applyLang(lang);
    var m = document.getElementById('lang-menu');
    if(m) m.classList.remove('show');
    document.querySelectorAll('.lang-menu button').forEach(function(b) {
      b.classList.toggle('active', b.getAttribute('data-lang') === lang);
    });
  };

  document.addEventListener('click', function(e) {
    if (!e.target.closest('.lang-select')) {
      var m = document.getElementById('lang-menu');
      if(m) m.classList.remove('show');
    }
  });

  // ===== RIPPLE =====
  document.addEventListener('click', function(e) {
    var btn = e.target.closest('.btn, .btn-submit, .btn-download');
    if (!btn) return;
    var r = document.createElement('span');
    r.className = 'ripple';
    var sz = Math.max(btn.offsetWidth, btn.offsetHeight);
    r.style.width = r.style.height = sz + 'px';
    r.style.left = (e.clientX - btn.getBoundingClientRect().left - sz/2) + 'px';
    r.style.top = (e.clientY - btn.getBoundingClientRect().top - sz/2) + 'px';
    btn.appendChild(r);
    setTimeout(function(){ r.remove(); }, 700);
  });

  // ===== SCROLL REVEAL =====
  var obs = new IntersectionObserver(function(entries) {
    entries.forEach(function(en) { if(en.isIntersecting) en.target.classList.add('visible'); });
  }, { threshold: 0.1, rootMargin: '0px 0px -40px 0px' });

  function initReveal() {
    document.querySelectorAll('.feature-card, .download-card, .review-card, .bug-card, .write-panel').forEach(function(el, i) {
      el.classList.add('reveal');
      el.classList.add('reveal-delay-' + ((i % 3) + 1));
      obs.observe(el);
    });
  }
  initReveal();

  // ===== COUNTS =====
  function loadCounts() {
    fetch('download.php?action=count&t=' + Date.now())
      .then(function(r){ return r.json(); })
      .then(function(d) {
        var el = function(id){ return document.getElementById(id); };
        if(el('dl-windows')) el('dl-windows').textContent = d.windows || 0;
        if(el('dl-linux')) el('dl-linux').textContent = d.linux || 0;
        if(el('dl-android')) el('dl-android').textContent = d.android || 0;
        if(el('total-downloads')) el('total-downloads').textContent = (d.windows||0)+(d.linux||0)+(d.android||0);
      }).catch(function(){});
  }
  loadCounts();
  setInterval(loadCounts, 15000);

  // ===== TABS =====
  window.showSection = function(name, btn) {
    document.querySelectorAll('.section-nav button').forEach(function(b){ b.classList.remove('active'); });
    btn.classList.add('active');
    document.querySelectorAll('.comm-section').forEach(function(s){ s.classList.remove('active'); });
    var sec = document.getElementById('sec-' + name);
    if(sec) sec.classList.add('active');
  };

  // ===== STARS =====
  var selRating = 5;
  var stars = document.querySelectorAll('#stars-in .s');
  function setStars(n) { selRating = n; stars.forEach(function(s){ s.classList.toggle('on', parseInt(s.getAttribute('data-v')) <= n); }); }
  stars.forEach(function(s){ s.onclick = function(){ setStars(parseInt(s.getAttribute('data-v'))); }; });
  setStars(5);

  // ===== COMMUNITY DATA =====
  var allReviews = [], allBugs = [];
  var ac = ['avatar-a','avatar-b','avatar-c','avatar-d','avatar-e'];

  function starsHTML(n) { var h=''; for(var i=0;i<n;i++) h+='\u2605'; for(var i=n;i<5;i++) h+='\u2606'; return h; }
  function timeAgo(d) {
    var diff = (Date.now() - new Date(d).getTime()) / 1000;
    if (diff < 60) return 'now'; if (diff < 3600) return Math.floor(diff/60) + 'm';
    if (diff < 86400) return Math.floor(diff/3600) + 'h'; return Math.floor(diff/86400) + 'd';
  }

  function loadReviews() {
    fetch('api.php?type=reviews&action=list&t=' + Date.now())
      .then(function(r){ return r.json(); }).then(function(d) {
        allReviews = d.items || [];
        var rc = document.getElementById('review-count');
        if(rc) rc.textContent = allReviews.length + ' ' + (T[currentLang]||T.en).comm_reviews_count;
        var ra = document.getElementById('review-avg');
        if(ra && allReviews.length) {
          var avg = allReviews.reduce(function(s,r){ return s+(r.rating||5); }, 0) / allReviews.length;
          ra.textContent = avg.toFixed(1);
        }
        renderReviews(allReviews);
      });
  }

  function renderReviews(items) {
    var el = document.getElementById('reviews-list');
    if (!el) return;
    if (!items.length) { el.innerHTML = '<div class="empty-state"><div class="icon">\u2605</div><p>'+(T[currentLang]||T.en).comm_empty_reviews+'</p></div>'; return; }
    el.innerHTML = items.map(function(r, i) {
      return '<div class="review-card"><div class="review-top"><div class="review-avatar '+ac[i%5]+'">'+r.name.charAt(0).toUpperCase()+'</div><div class="review-info"><div><span class="review-name">'+r.name+'</span><span class="review-platform">'+(r.platform||'')+'</span></div><div class="review-stars">'+starsHTML(r.rating||5)+'</div></div><div class="review-date">'+timeAgo(r.date)+'</div></div><div class="review-text">'+r.message+'</div></div>';
    }).join('');
    initReveal();
  }

  window.filterReviews = function(f, btn) {
    document.querySelectorAll('#sec-reviews .filter-btn').forEach(function(b){ b.classList.remove('active'); });
    btn.classList.add('active');
    if (f === 'all') return renderReviews(allReviews);
    if (f === 'low') return renderReviews(allReviews.filter(function(r){ return (r.rating||5)<=2; }));
    renderReviews(allReviews.filter(function(r){ return String(r.rating||5)===f; }));
  };

  function loadBugs() {
    fetch('api.php?type=bugs&action=list&t=' + Date.now())
      .then(function(r){ return r.json(); }).then(function(d) {
        allBugs = d.items || [];
        var bc = document.getElementById('bug-count');
        if(bc) bc.textContent = allBugs.length + ' ' + (T[currentLang]||T.en).comm_bugs_count;
        var bo = document.getElementById('bug-open-count');
        if(bo) bo.textContent = allBugs.filter(function(b){ return b.status!=='fixed'; }).length + ' ' + (T[currentLang]||T.en).comm_bugs_open;
        renderBugs(allBugs);
      });
  }

  function renderBugs(items) {
    var el = document.getElementById('bugs-list');
    if (!el) return;
    if (!items.length) { el.innerHTML = '<div class="empty-state"><div class="icon">\u26a1</div><p>'+(T[currentLang]||T.en).comm_empty_bugs+'</p></div>'; return; }
    el.innerHTML = items.map(function(b) {
      return '<div class="bug-card"><div class="bug-icon bug-open">\u26a1</div><div class="bug-body"><div class="bug-title">'+b.title+'</div><div class="bug-meta"><span><span class="severity-dot dot-'+b.severity+'"></span>'+b.severity+'</span><span>'+b.name+'</span><span>'+(b.platform||'')+(b.version?' v'+b.version:'')+'</span><span>'+timeAgo(b.date)+'</span><span class="bug-label label-'+(b.status||'new')+'">'+(b.status||'new')+'</span></div><div class="bug-desc">'+b.message+'</div>'+(b.steps?'<div class="bug-steps"><strong>'+(T[currentLang]||T.en).comm_steps_label+'</strong><pre>'+b.steps+'</pre></div>':'')+'</div></div>';
    }).join('');
    initReveal();
  }

  window.filterBugs = function(f, btn) {
    document.querySelectorAll('#sec-bugs .filter-btn').forEach(function(b){ b.classList.remove('active'); });
    btn.classList.add('active');
    if (f === 'all') return renderBugs(allBugs);
    renderBugs(allBugs.filter(function(b){ return b.severity===f; }));
  };

  // ===== FORM SUBMITS =====
  var rf = document.getElementById('review-form');
  if (rf) rf.onsubmit = function(e) {
    e.preventDefault();
    var btn = document.getElementById('r-btn');
    btn.disabled = true; btn.textContent = '...';
    fetch('api.php?type=reviews',{method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({name:document.getElementById('r-name').value,message:document.getElementById('r-msg').value,rating:selRating,platform:document.getElementById('r-platform').value})
    }).then(function(r){return r.json();}).then(function(d){
      var m=document.getElementById('r-msg-box');
      if(d.success){m.className='form-msg ok';m.textContent='\u2713';rf.reset();setStars(5);loadReviews();setTimeout(function(){showSection('reviews',document.querySelector('.section-nav button'));},1200);}
      else{m.className='form-msg err';m.textContent=d.error||'Failed';}
      btn.disabled=false;btn.textContent=(T[currentLang]||T.en).comm_submit_review;
    }).catch(function(){btn.disabled=false;btn.textContent=(T[currentLang]||T.en).comm_submit_review;});
  };

  var bf = document.getElementById('bug-form');
  if (bf) bf.onsubmit = function(e) {
    e.preventDefault();
    var btn = document.getElementById('b-btn');
    btn.disabled = true; btn.textContent = '...';
    fetch('api.php?type=bugs',{method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({name:document.getElementById('b-name').value,message:document.getElementById('b-msg').value,title:document.getElementById('b-title').value,
        platform:document.getElementById('b-platform').value,version:document.getElementById('b-version').value,severity:document.getElementById('b-severity').value,steps:document.getElementById('b-steps').value})
    }).then(function(r){return r.json();}).then(function(d){
      var m=document.getElementById('b-msg-box');
      if(d.success){m.className='form-msg ok';m.textContent='\u2713';bf.reset();loadBugs();setTimeout(function(){showSection('bugs',document.querySelector('.section-nav button'));},1200);}
      else{m.className='form-msg err';m.textContent=d.error||'Failed';}
      btn.disabled=false;btn.textContent=(T[currentLang]||T.en).comm_submit_bug;
    }).catch(function(){btn.disabled=false;btn.textContent=(T[currentLang]||T.en).comm_submit_bug;});
  };

  // ===== OS DETECT =====
  var u = navigator.userAgent, os = 'unknown';
  if (u.indexOf('Win')>-1) os='windows';
  else if (u.indexOf('Linux')>-1 && u.indexOf('Android')===-1) os='linux';
  else if (u.indexOf('Android')>-1) os='android';
  else if (u.indexOf('Mac')>-1) os='linux';
  document.querySelectorAll('.download-card').forEach(function(c){ if(c.getAttribute('data-os')===os) c.classList.add('featured'); });

  // ===== INIT =====
  applyLang(currentLang);
  document.querySelectorAll('.lang-menu button').forEach(function(b){
    b.classList.toggle('active', b.getAttribute('data-lang')===currentLang);
  });
  var ti = document.getElementById('theme-icon');
  if(ti) ti.textContent = savedTheme==='dark' ? '\ud83c\udf19' : '\u2600\ufe0f';
  loadReviews();
  loadBugs();

})();
