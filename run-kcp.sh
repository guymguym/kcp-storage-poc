source $(dirname $0)/env.sh

kcp start \
  $FEATURE_GATES \
  --token-auth-file=test/e2e/framework/auth-tokens.csv
