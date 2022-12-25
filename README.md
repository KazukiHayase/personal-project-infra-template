# 個人開発用のインフラのテンプレート

# リソース作成手順

1. GCPのプロジェクトを作成
1. gcloudコマンドの向き先を作成したプロジェクトにする
1. `make init`
    1. `Makefile`の`GCP_PROJECT_ID`にGCPのプロジェクトIDを入れる
1. [NEON](https://neon.tech/)でDBを作成
1. 作成したDBのURLを、GCPのコンソール上からシークレットマネージャーに登録
1. Terraform CloudでWorkspacesを作成してApply
