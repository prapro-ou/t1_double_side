# SceneManager

## 概要
sceneを切り替えるための自動読み込みノード。
SceneManager.change_scene(key:String)にとって登録されているsceneに遷移される。

このオブジェクトはsceneどうしの循環参照をさけるため、scene間での変数の受け渡しを行うために作成された。
原則、全てのscene遷移はこのノードを通じて行われる。
