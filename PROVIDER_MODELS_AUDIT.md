# Audit des modèles free-tier — TOCR

**Vérification effectuée le 26 septembre 2026.** Les offres, alias et quotas peuvent changer; le catalogue API authentifié du compte et la console du fournisseur restent la référence pour le déploiement.

## Résumé des intégrations

| Provider | Modèles activés dans `opencode.json` | Statut du « gratuit » |
| --- | --- | --- |
| Atria ASI | `Atria-Dawn-Preview` | Le modèle et l’API sont officiels; **aucune source officielle consultée ne confirme une quantité de quota gratuite**. Ajouté avec avertissement, pas compté comme gratuit vérifié. |
| FreeTheAI | 11 alias | FreeTheAI indique une API à 0¢; inscription Discord et `/checkin` quotidien requis. Les alias ont été comparés au catalogue `/v1/models/full` en direct; les lignes sans rôle requis sont celles retenues. |
| Google Gemini | 10 modèles | Modèles dont l’API officielle indique un prix d’entrée et de sortie à zéro en Free Tier. Les limites sont par projet et peuvent changer. |
| Mistral | 6 modèles conversationnels actuels | Le plan Free comprend **10 USD/mois de crédits API** selon la page tarifaire, et non une gratuité illimitée par modèle. Un dépassement peut être payant si le pay-as-you-go est activé. |
| NVIDIA NIM | 10 endpoints | Les modèles proviennent du filtre officiel « Free Endpoint »; accès d’essai soumis au compte NVIDIA/validation, aux limites et aux conditions de l’API Trial. Gratuité/quota non garanti au-delà des limites publiées. |

## Modèles et corrections à connaître

### Atria ASI

- L’API officielle confirme le modèle exact `Atria-Dawn-Preview`, le endpoint compatible OpenAI `https://api.atria-asi.ai/v1` et une fenêtre de contexte de 256K.
- Le fichier fourni évoque environ 100M tokens gratuits selon des témoignages communautaires et renvoie au solde de console, mais je n’ai pas trouvé de confirmation officielle publique du montant ou des conditions. **Ne pas traiter ce modèle comme gratuit garanti** avant de contrôler le crédit affiché dans le compte Atria.

### FreeTheAI

- La documentation officielle confirme la base URL, le préfixe d’alias `opc/`, la gratuité du niveau de base, l’obligation de `/checkin` chaque jour UTC et les erreurs `model_access_denied` pour les modèles réservés aux rôles Verified.
- Les IDs activés sont confirmés présents dans le catalogue live obtenu via `/v1/models/full`; aucun n’affichait un rôle Discord requis lors de cette vérification. Le catalogue peut évoluer; `GET /v1/models` authentifié avec la clé du déploiement est le contrôle final.
- **Retiré :** `opc/deepseek-v4-flash-free` du fichier existant, absent du catalogue live au moment de la vérification. L’alias documenté par l’exemple officiel est `opc/deepseek-v4-flash-free`, mais le service ne le renvoyait pas dans le catalogue accessible : ne pas le considérer utilisable sans qu’il réapparaisse dans `/v1/models`.
- Le ZIP proposait aussi `opc/mimo-v2.5-free`, `opc/nemotron-3-ultra-free`, `opc/north-mini-code-free`, `kai/poolside/laguna-xs-2.1:free`, `kai/stepfun/step-3.7-flash:free`, `opc/big-pickle`, et `kai/openrouter/free`. Les deux derniers et les alias kai Step/Laguna étaient présents en direct; Mimo V2.5 et North Mini sous le préfixe `opc/` ne l’étaient pas. Nemotron `opc/nemotron-3-ultra-free` était présent et est activé. Cohere North Mini reste activé sous son ID live `kai/cohere/north-mini-code:free`.
- Un modèle absent du catalogue doit être retiré ou réactivé seulement après confirmation via le endpoint live avec la clé propre au compte. La liste inclut également GLM-5.1 et les alias déjà existants qui figuraient dans le catalogue live.

### Google Gemini

- La page officielle des tarifs affiche à **0 USD input/output** en Free Tier les modèles configurés : Gemini 3.8 Flash, 3.7 Flash, 3.6 Flash, 3.5 Flash, 3.5 Flash-Lite, 3.1 Flash-Lite, Gemini 2.5 Pro, Gemini 2.5 Flash, Gemini 2.5 Flash-Lite et Gemma 4.
- **À ne pas confondre :** `gemini-3.1-pro-preview` est indiqué **Not available** en Free Tier sur la page de tarification officielle; exclu de la configuration gratuite. Les modèles Gemini 3.x ont des tarifs payants, même si le compte/projet ne dispose pas du free tier correspondant.
- `gemini-2.0-flash` était marqué « legacy » dans le ZIP; il n’a pas été activé car le catalogue/pricing courant consulté ne permettait pas d’en confirmer le statut gratuit actuel.
- Les quotas de requêtes/tokens dépendent du projet Google AI Studio; toute option de grounding ou d’outil peut avoir un régime tarifaire distinct.

### Mistral

- Les docs Mistral disent que le plan Free permet une clé API et une utilisation incluse dans les limites visibles dans la console. La page de prix publique annonce **10 USD/mois de crédits API** avec le plan Free; ce montant est un crédit, pas une promesse que chaque appel est intrinsèquement à 0 USD.
- Modèles de chat ajoutés avec les IDs actuels indiqués par les fiches officielles : `mistral-large-2512`, `mistral-medium-3-5`, `mistral-small-2603`, `codestral-2508`, `ministral-3b-2512`, `ministral-8b-2512`. Leur utilisation est donc gratuite uniquement dans la limite de crédits inclus et sous réserve de l’éligibilité effective du workspace.
- **Risque de frais :** les prix affichés pour certains modèles sont, par exemple, Mistral Large 3 : 0,50 USD/M tokens input et 1,50 USD/M output; Medium 3.5 : 1,50/7,50; Small 4 : 0,15/0,60. Vérifier l’état PAYG du compte et les limites dans Admin → API Limits avant production.
- `open-mistral-nemo` a été retiré de la liste active : la page officielle le marque retiré le 31 juillet 2026. `voxtral-mini-latest` n’est pas un modèle de chat texte (transcription audio) et n’a pas été intégré au sélecteur conversationnel OpenCode. Les anciens alias `*-latest` du fichier ont été remplacés par des IDs versionnés actuels.

### NVIDIA NIM

- Les 10 IDs activés viennent du fichier fourni et des entrées présentes sur la page officielle Build filtrée « Free Endpoint ». Le point d’entrée OpenAI-compatible utilisé est `https://integrate.api.nvidia.com/v1`.
- Il s’agit d’endpoints d’essai/de développement, pas d’une offre de production ou d’une gratuité sans limite. La création de clé peut exiger un compte NVIDIA Developer et une vérification téléphonique; respecter les quotas et les conditions d’essai en vigueur.

## Variables d’environnement ajoutées

- `ATRIA_API_KEY`
- `NVIDIA_API_KEY`

Les autres clés existaient déjà dans le projet. Les clés ne sont pas écrites dans le dépôt; seules des références `{env:...}` sont utilisées.

## Sources officielles principales

- [Atria API docs](https://api.atria-asi.ai/docs) — modèle, API, contexte; ne publie pas de quota gratuit chiffré.
- [FreeTheAI API docs](https://freetheai.xyz/docs) et [catalogue](https://freetheai.xyz/models) — auth, check-in, erreurs d’accès, alias; catalogue API live vérifié le 26/09/2026.
- [Google Gemini API pricing](https://ai.google.dev/gemini-api/docs/pricing) et [models](https://ai.google.dev/gemini-api/docs/models).
- [Mistral pricing](https://mistral.ai/pricing/), [Free usage limits](https://docs.mistral.ai/admin/billing-usage/usage-limits), [models](https://docs.mistral.ai/models).
- [NVIDIA Free Endpoints](https://build.nvidia.com/models?label=free+endpoint) et [API Trial Terms](https://assets.ngc.nvidia.com/products/api-catalog/legal/NVIDIA%20API%20Trial%20Terms%20of%20Service.pdf).
- [OpenCode custom provider docs](https://opencode.ai/docs/providers/).
