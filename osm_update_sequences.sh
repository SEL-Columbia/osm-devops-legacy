#!/bin/bash

# start postgres
service postgresql start

cat - > /tmp/update_seqs.sql << EOF
select setval('acls_id_seq', (select max(id) from acls)); 
select setval('changesets_id_seq', (select max(id) from changesets)); 
select setval('client_applications_id_seq', (select max(id) from client_applications)); 
select setval('countries_id_seq', (select max(id) from countries)); 
select setval('current_nodes_id_seq', (select max(id) from current_nodes)); 
select setval('current_relations_id_seq', (select max(id) from current_relations)); 
select setval('current_ways_id_seq', (select max(id) from current_ways)); 
select setval('diary_comments_id_seq', (select max(id) from diary_comments)); 
select setval('diary_entries_id_seq', (select max(id) from diary_entries)); 
select setval('friends_id_seq', (select max(id) from friends)); 
select setval('gpx_file_tags_id_seq', (select max(id) from gpx_file_tags)); 
select setval('gpx_files_id_seq', (select max(id) from gpx_files)); 
select setval('messages_id_seq', (select max(id) from messages)); 
select setval('oauth_nonces_id_seq', (select max(id) from oauth_nonces)); 
select setval('oauth_tokens_id_seq', (select max(id) from oauth_tokens)); 
select setval('redactions_id_seq', (select max(id) from redactions)); 
select setval('user_blocks_id_seq', (select max(id) from user_blocks)); 
select setval('user_roles_id_seq', (select max(id) from user_roles)); 
select setval('user_tokens_id_seq', (select max(id) from user_tokens)); 
select setval('users_id_seq', (select max(id) from users));
EOF

timeout_seconds=20
while ( ! sudo -u postgres psql -d osm -c "\l" )
do
  [[ $timeout_seconds > 0 ]] || { echo "failed to connect to postgres" >&2; exit 1; } 
  timeout_seconds=$((timeout_seconds-1))
  sleep 1
done


sudo -u postgres psql osm_dev -f /tmp/update_seqs.sql
sudo -u postgres psql osm -f /tmp/update_seqs.sql
