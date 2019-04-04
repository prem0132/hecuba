package utils

import (
	"fmt"
	"log"

	"github.com/gocql/gocql"
)

// AddData function  to add data to cassandra
func AddData(cassIP, name string) string {
	cluster := gocql.NewCluster(cassIP)
	cluster.Keyspace = "example"
	cluster.Consistency = gocql.Quorum
	session, _ := cluster.CreateSession()
	defer session.Close()

	// insert a tweet
	if err := session.Query(`INSERT INTO tweet (timeline, id, text) VALUES ( ? , ? , ? )`,
		"me", gocql.TimeUUID(), name).Exec(); err != nil {
		log.Fatal(err)
	}

	var id gocql.UUID
	var text string

	/* Search for a specific set of records whose 'timeline' column matches
	 * the value 'me'. The secondary index that we created earlier will be
	 * used for optimizing the search */
	if err := session.Query(`SELECT id, text FROM tweet WHERE timeline = ? LIMIT 1`,
		"me").Consistency(gocql.One).Scan(&id, &text); err != nil {
		log.Fatal(err)
	}
	fmt.Println("You tweeted:", id, text)
	tweet := ""
	// list all tweets
	iter := session.Query(`SELECT id, text FROM tweet WHERE timeline = ?`, "me").Iter()
	for iter.Scan(&id, &text) {
		//fmt.Println("Tweet:", id, text)
		tweet = "Tweet " + " " + text
	}
	if err := iter.Close(); err != nil {
		log.Fatal(err)
	}

	return string(tweet)
}

// Reverse function
func Reverse(s string) string {
	b := []byte(s)
	for i := 0; i < len(b)/2; i++ {
		j := len(b) - i - 1
		b[i], b[j] = b[j], b[i]
	}
	return string(b)
}
