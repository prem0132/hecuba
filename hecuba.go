/* Before you execute the program, Launch `cqlsh` and execute:
create keyspace example with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
create table example.tweet(timeline text, id UUID, text text, PRIMARY KEY(id));
create index on example.tweet(timeline);
*/
package main

import (
	"log"
	"os"

	"github.com/prem0132/hecuba/pkg/utils"
)

func main() {
	adddata := utils.AddData(os.Args[1], os.Args[2])
	log.Println(adddata)
}
