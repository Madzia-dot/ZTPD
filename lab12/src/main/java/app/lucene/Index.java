package app.lucene;

import org.apache.lucene.analysis.pl.PolishAnalyzer;
import org.apache.lucene.document.*;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.FSDirectory;
import java.nio.file.Paths;

public class Index {
    public static void main(String[] args) throws Exception {
        String indexPath = "index_dir";
        PolishAnalyzer analyzer = new PolishAnalyzer();
        Directory directory = FSDirectory.open(Paths.get(indexPath));

        IndexWriterConfig config = new IndexWriterConfig(analyzer);
        IndexWriter w = new IndexWriter(directory, config);


        addDoc(w, "Lucyna w akcji", "9780062316097");
        addDoc(w, "Akcje rosną i spadają", "9780385545955");
        addDoc(w, "Bo ponieważ", "9781501168007");
        addDoc(w, "Naturalnie urodzeni mordercy", "9780316485616");
        addDoc(w, "Druhna rodzi", "9780593301760");
        addDoc(w, "Urodzić się na nowo", "9780679777489");

        w.close();
        System.out.println("Indeks utworzony w folderze: " + indexPath);
    }

    private static void addDoc(IndexWriter w, String title, String isbn) throws Exception {
        Document doc = new Document();
        doc.add(new TextField("title", title, Field.Store.YES));
        doc.add(new StringField("isbn", isbn, Field.Store.YES));
        w.addDocument(doc);
    }
}
