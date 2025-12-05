import pandas as pd
import ast

# Dosyayı oku (Kaggle'dan indirdiğin dosya adı)
print("Dosya okunuyor, biraz sürebilir...")
df = pd.read_csv('RAW_recipes.csv')

# Sadece işimize yarayan sütunları alalım
# nutrition sütunu formatı: [cal, fat, sugar, sodium, protein, sat_fat, carbs]
keep_cols = ['name', 'ingredients', 'nutrition', 'steps', 'description', 'minutes']
df = df[keep_cols]

# Temizleme Fonksiyonları
def parse_nutrition(text):
    """
    '[51.5, 0.0, 13.0, 0.0, 2.0, 0.0, 4.0]' gibi gelen veriyi parçalar.
    Sıralama genelde: [Kalori, Toplam Yağ, Şeker, Sodyum, Protein, Doymuş Yağ, Karbonhidrat]
    """
    try:
        nut_list = ast.literal_eval(text)
        return {
            "calories": nut_list[0],
            "fat": nut_list[1],
            "protein": nut_list[4],
            "carbs": nut_list[6]
        }
    except:
        return {"calories": 0, "fat": 0, "protein": 0, "carbs": 0}

def clean_text_list(text):
    """ '["un", "tuz"]' stringini gerçek listeye çevirir """
    try:
        return ast.literal_eval(text)
    except:
        return []

print("Veriler temizleniyor ve besin değerleri ayrıştırılıyor...")

# Dönüşümleri uygula
df['nutrition_info'] = df['nutrition'].apply(parse_nutrition)
df['ingredients'] = df['ingredients'].apply(clean_text_list)
df['steps'] = df['steps'].apply(clean_text_list)

# Gereksiz nutrition string sütununu sil, temiz olanı kalsın
df = df.drop(columns=['nutrition'])

# Çok uzun veya boş tarifleri ele (Mobil uygulama çökmesin)
df = df.dropna()
df = df[df['ingredients'].map(len) > 0] 

# İlk 5000 popüler tarifi alalım (Tümünü almak istersen bu satırı sil)
# Mobil uygulamada test ederken dosya boyutu küçük olsun diye 5000 yaptık.
df_final = df.head(5000)

# JSON olarak kaydet
output_file = 'hazir_tarifler.json'
df_final.to_json(output_file, orient='records', force_ascii=False)

print(f"İşlem tamam! '{output_file}' dosyası oluşturuldu.")
print("Bu dosyayı Flutter/React Native projenin 'assets' klasörüne atabilirsin.")