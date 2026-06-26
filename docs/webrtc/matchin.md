# matching

## 概要
matchingはWebRTCを用いて実装されている。
また、WebRTCをネイティブでも動作させるためにGDExtensionである`webrtc-native`を導入した

ホストと参加者に分かれ、ホストが部屋をたて、参加者がそこに参加。
部屋に参加するとWebRTCによってP2Pが開始される。
その後、ホストがゲーム開始を押すと、シグナリングサーバーから切断される。

これらの処理は`script/utils/network_manager.gd`が行っており、オートロードで`NetworkManager`という名称で他のスクリプトからアクセスできる。
