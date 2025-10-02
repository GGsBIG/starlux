# PostgreSQL 在 Kubernetes 中的部署指南

## 目錄
- [概述](#概述)
- [先決條件](#先決條件)
- [PostgreSQL 映像檔準備](#postgresql-映像檔準備)
- [部署步驟](#部署步驟)
- [資料庫初始化](#資料庫初始化)
- [資料庫查詢](#資料庫查詢)
- [連線資訊](#連線資訊)
- [常用命令](#常用命令)
- [故障排除](#故障排除)

---

## 概述

本指南說明如何在 Kubernetes 集群中部署 PostgreSQL 資料庫，並提供完整的初始化和管理腳本。

**配置說明：**
- **資料庫版本**: PostgreSQL 16.4 (bookworm)
- **命名空間**: gravity2-lab
- **服務名稱**: target3-postgres
- **NodePort**: 30432
- **儲存空間**: 2Gi PVC
- **預設資料庫**: testdb
- **使用者**: postgres
- **密碼**: 1qaz@WSX

---

## 先決條件

1. **Kubernetes 集群已正常運行**
2. **kubectl 命令列工具已配置**
3. **命名空間 `gravity2-lab` 已存在**
   ```bash
   kubectl create namespace gravity2-lab
   ```
4. **containerd 運行時環境 (使用 ctr 命令)**

---

## PostgreSQL 映像檔準備

### 方法一：使用 containerd 拉取映像檔

```bash
# 拉取 PostgreSQL 16.4 映像檔到 k8s.io 命名空間
sudo ctr -n k8s.io images pull docker.io/library/postgres:16.4-bookworm

# 驗證映像檔已成功拉取
sudo ctr -n k8s.io images ls | grep postgres
```

### 方法二：使用 crictl 拉取映像檔

```bash
# 使用 crictl 拉取映像檔
sudo crictl pull postgres:16.4-bookworm

# 列出所有映像檔
sudo crictl images | grep postgres
```

### 方法三：使用 docker 拉取並匯入 (若使用 Docker)

```bash
# 拉取映像檔
docker pull postgres:16.4-bookworm

# 儲存映像檔為 tar 檔案
docker save -o postgres-16.4.tar postgres:16.4-bookworm

# 使用 ctr 匯入映像檔
sudo ctr -n k8s.io images import postgres-16.4.tar

# 清理 tar 檔案
rm postgres-16.4.tar
```

### 映像檔標籤說明

```bash
# 查看映像檔詳細資訊
sudo ctr -n k8s.io images ls -q | grep postgres

# 預期輸出範例
# docker.io/library/postgres:16.4-bookworm
```

---

## 部署步驟

### 1. 切換到專案目錄

```bash
cd /Users/tianjiasong/starlux/10-lab-db/target3-postgres
```

### 2. 部署 PostgreSQL 到 Kubernetes

```bash
# 套用 YAML 配置檔
kubectl apply -f postgres.yaml

# 預期輸出
# persistentvolumeclaim/target3-postgres-volume created
# service/target3-postgres created
# deployment.apps/target3-postgres created
```

### 3. 驗證部署狀態

```bash
# 檢查 Pod 狀態
kubectl -n gravity2-lab get pods | grep target3-postgres

# 檢查 Service 狀態
kubectl -n gravity2-lab get svc target3-postgres

# 檢查 PVC 狀態
kubectl -n gravity2-lab get pvc target3-postgres-volume

# 查看 Pod 詳細資訊
kubectl -n gravity2-lab describe pod <pod-name>

# 查看 Pod 日誌
kubectl -n gravity2-lab logs -f <pod-name>
```

### 4. 等待 Pod 就緒

```bash
# 等待 Pod 狀態變為 Running
kubectl -n gravity2-lab wait --for=condition=ready pod -l name=target3-postgres --timeout=300s
```

---

## 資料庫初始化

### 建立資料表

使用提供的腳本建立 `target_id13` 資料表：

```bash
# 賦予執行權限
chmod +x 01-create_target3_db.sh

# 執行建表腳本
./01-create_target3_db.sh
```

**腳本說明 (`01-create_target3_db.sh`)：**
- 自動尋找 target3-postgres 的 Pod
- 使用 `psql` 命令列工具執行 SQL 檔案
- 讀取 `Target3Table.sql` 並在 testdb 資料庫中建立資料表

**資料表結構 (`Target3Table.sql`)：**
- 主鍵: `gravity_pk` (VARCHAR 48)
- 包含 33 個欄位，用於儲存病床資料
- 所有欄位皆為 VARCHAR 或 INTEGER 類型

---

## 資料庫查詢

### 使用查詢腳本

```bash
# 賦予執行權限
chmod +x 02-query_target3.sh

# 執行查詢腳本
./02-query_target3.sh
```

**腳本說明 (`02-query_target3.sh`)：**
- 查詢 `target_id13` 資料表的所有資料
- 使用 PGPASSWORD 環境變數傳遞密碼
- 輸出格式化的查詢結果

### 手動執行 SQL 查詢

```bash
# 設定變數
ns=gravity2-lab
pod=$(kubectl -n ${ns} get pods | awk '/^target3-postgres-/{print $1}')

# 進入 PostgreSQL Shell
kubectl -n ${ns} exec -it ${pod} -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb"

# 在 psql 中執行查詢
# testdb=# SELECT COUNT(*) FROM target_id13;
# testdb=# \dt              -- 列出所有資料表
# testdb=# \d target_id13   -- 查看資料表結構
# testdb=# \q               -- 退出
```

### 常用 SQL 查詢範例

```sql
-- 查詢資料總數
SELECT COUNT(*) FROM target_id13;

-- 查詢所有資料
SELECT * FROM target_id13;

-- 查詢特定欄位
SELECT gravity_pk, bdl_id, bdl_pat_no FROM target_id13;

-- 查詢前 10 筆資料
SELECT * FROM target_id13 LIMIT 10;

-- 查詢資料表結構
\d target_id13
```

---

## 連線資訊

### 叢集內部連線

```yaml
Host: target3-postgres.gravity2-lab.svc.cluster.local
Port: 5432
Database: testdb
User: postgres
Password: 1qaz@WSX
```

### 叢集外部連線 (NodePort)

```yaml
Host: <Node-IP>
Port: 30432
Database: testdb
User: postgres
Password: 1qaz@WSX
```

**取得 Node IP：**
```bash
kubectl get nodes -o wide
```

### 連線字串範例

```bash
# psql 連線字串
psql -h <Node-IP> -p 30432 -U postgres -d testdb

# JDBC 連線字串
jdbc:postgresql://<Node-IP>:30432/testdb

# Python psycopg2 連線
import psycopg2
conn = psycopg2.connect(
    host="<Node-IP>",
    port=30432,
    database="testdb",
    user="postgres",
    password="1qaz@WSX"
)
```

---

## 常用命令

### Pod 管理

```bash
# 查看 Pod 列表
kubectl -n gravity2-lab get pods

# 查看 Pod 詳細資訊
kubectl -n gravity2-lab describe pod <pod-name>

# 查看 Pod 日誌
kubectl -n gravity2-lab logs -f <pod-name>

# 進入 Pod Shell
kubectl -n gravity2-lab exec -it <pod-name> -- bash

# 重啟 Pod (刪除後自動重建)
kubectl -n gravity2-lab delete pod <pod-name>
```

### 資料庫管理

```bash
# 進入 psql 命令列
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb"

# 直接執行 SQL 查詢
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb -c 'SELECT version();'"

# 列出所有資料庫
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -l"

# 備份資料庫
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' pg_dump -U postgres testdb" > backup.sql

# 還原資料庫
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb" < backup.sql
```

### 資源清理

```bash
# 刪除部署 (保留 PVC)
kubectl -n gravity2-lab delete deployment target3-postgres
kubectl -n gravity2-lab delete service target3-postgres

# 完全清理 (包含資料)
kubectl delete -f postgres.yaml

# 只刪除 PVC (會刪除所有資料)
kubectl -n gravity2-lab delete pvc target3-postgres-volume
```

---

## 故障排除

### Pod 無法啟動

```bash
# 檢查 Pod 狀態
kubectl -n gravity2-lab describe pod <pod-name>

# 檢查 Pod 事件
kubectl -n gravity2-lab get events --sort-by='.lastTimestamp' | grep target3-postgres

# 檢查 Pod 日誌
kubectl -n gravity2-lab logs <pod-name>

# 常見問題：
# 1. 映像檔拉取失敗 -> 確認映像檔是否已在節點上
# 2. PVC 綁定失敗 -> 檢查 StorageClass 配置
# 3. 密碼認證失敗 -> 確認環境變數設定正確
```

### 無法連線到資料庫

```bash
# 檢查 Service 是否正常
kubectl -n gravity2-lab get svc target3-postgres

# 檢查 Service Endpoints
kubectl -n gravity2-lab get endpoints target3-postgres

# 測試 Pod 網路連線
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "pg_isready -U postgres"

# 從其他 Pod 測試連線
kubectl -n gravity2-lab run -it --rm debug --image=postgres:16.4-bookworm --restart=Never -- bash -c "PGPASSWORD='1qaz@WSX' psql -h target3-postgres -U postgres -d testdb -c 'SELECT 1;'"
```

### 資料表不存在

```bash
# 確認資料表列表
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb -c '\dt'"

# 重新執行建表腳本
./01-create_target3_db.sh

# 手動建立資料表
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb -f /dev/stdin" < Target3Table.sql
```

### 映像檔相關問題

```bash
# 檢查節點上的映像檔
sudo ctr -n k8s.io images ls | grep postgres

# 重新拉取映像檔
sudo ctr -n k8s.io images pull docker.io/library/postgres:16.4-bookworm

# 檢查映像檔 SHA
sudo ctr -n k8s.io images ls -q docker.io/library/postgres:16.4-bookworm

# 刪除舊映像檔
sudo ctr -n k8s.io images rm docker.io/library/postgres:16.4-bookworm
```

### 效能調優

```bash
# 檢查資料庫統計資訊
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb -c 'SELECT * FROM pg_stat_database WHERE datname = '\''testdb'\'';'"

# 檢查資料表大小
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb -c 'SELECT pg_size_pretty(pg_total_relation_size('\''target_id13'\''));'"

# 執行 VACUUM
kubectl -n gravity2-lab exec -it <pod-name> -- bash -c "PGPASSWORD='1qaz@WSX' psql -U postgres -d testdb -c 'VACUUM ANALYZE target_id13;'"
```

---

## 檔案結構

```
target3-postgres/
├── postgres.yaml              # Kubernetes 部署配置檔
├── Target3Table.sql           # 資料表建立 SQL
├── 01-create_target3_db.sh   # 建表腳本
├── 02-query_target3.sh       # 查詢腳本
└── README.md                  # 本文件
```

---

## 參考資料

- [PostgreSQL 官方文件](https://www.postgresql.org/docs/16/)
- [Kubernetes 官方文件](https://kubernetes.io/docs/home/)
- [containerd 映像檔管理](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)

---

## 版本資訊

- **PostgreSQL**: 16.4-bookworm
- **Kubernetes API**: apps/v1
- **文件版本**: 1.0
- **最後更新**: 2025-10-01
