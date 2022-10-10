source "$(dirname $0)/env.sh"

kcp start \
  --feature-gates=KCPLocationAPI=true \
  --token-auth-file=test/e2e/framework/auth-tokens.csv
