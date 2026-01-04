package app.lucene;

import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.StoredFields;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.*;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import java.nio.file.Paths;

public class Search {
    public static void main(String[] args) throws Exception {
        String indexPath = "index_dir";
        Directory directory = FSDirectory.open(Paths.get(indexPath));

        IndexReader reader = DirectoryReader.open(directory);
        IndexSearcher searcher = new IndexSearcher(reader);

        PolishAnalyzer analyzer = new PolishAnalyzer();
        String querystr = "*:*";

        Query q = new QueryParser("title", analyzer).parse(querystr);

        TopDocs docs = searcher.search(q, 10);
        ScoreDoc[] hits = docs.scoreDocs;

        System.out.println("Wyniki wyszukiwania dla: " + querystr);
        StoredFields storedFields = searcher.storedFields();

        for (int i = 0; i < hits.length; ++i) {
            Document d = storedFields.document(hits[i].doc);
            System.out.println((i + 1) + ". " + d.get("isbn") + "\t" + d.get("title"));
        }

        reader.close();
    }
}
// Uruchomienie programu tworzącego indeks dwa razy spowodowało zduplikowanie dokumentów w wynikach wyszukiwania, ponieważ każde kolejne wywołanie IndexWriter dodaje nowe segmenty z danymi do istniejącego katalogu na dysku