class Api::RestaurantsController < ApplicationController
  before_action :set_google_places_client, only: [:index, :restaurant_details]

  def index
    return render_error(:bad_request, '位置情報が提供されていません') if params[:latitude].blank? || params[:longitude].blank?

    restaurants = fetch_restaurants

    return render_error(:not_found, 'レストランが見つかりません') if restaurants.blank?

    processed_restaurants = process_restaurant_data(restaurants)

    # テスト用レストランデータ
    # processed_restaurants = [ {"place_id":"ChIJYVpVM4FfGGARm3dvazTwDQE","name":"博多ラーメン 長浜や 元住吉店（ながはまや）","lat":35.5649357,"lng":139.6554096,"vicinity":"川崎市中原区木月２丁目２−３８","rating":3.1,"price_level":1,"photos":["https://lh3.googleusercontent.com/places/ANXAkqFcXDDuYXETZ-bS3I1fJE4iex_NY_I8WiVzWpbsg6yXfA8y2w2GumUAWfqLzKiBOp_PR_YYJXGK9LOudNtb_qszhzxmrIIPDbc=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFJu8B83cAmhHGIwg0-wQ4QBGhcyp_xOAYHY7eZFgCWw_BioUEUOIoC3dIhe1U_5oq3hdNT3YvdjuiXCU6oKyvdVHOz2t4mb7g=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGXgVf8cr3c6iUUnhxzMB3zcYDyrJ_2pNFMte_s95499Em7Jx8ikhGfyfXOg_7acbMfKRy8wfcRZdM-X61pqnQCEsjaEpdCgxM=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqERdvN1PECLmPw_yxTBd5C0Irj5i7vReBAXMcNtNbyScYqazlcg4GNQ-rObcWdxWia9eWFbojTnukNZA94vxeGadEtIMmwBtEQ=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHK3xITYp13chfeS99SRCuQSzTuvU6YJ3_Q3Y7RYVlYh9KXMEfNvSSf3Q9uxhly2eXYt2_WKVno68qA_yd4EHAPOvlcv9ykDd8=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHAF74CjhWZDqgKcpWTokfIyzIu0PjPp7sb4gGjtThxJ_NkLDMcGqfYmgUzETwka7nslLO0ix1Lelunky2QR5-lDrP8_zFSTDw=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGADZHg6aidT-kJ_jrrHqJosN2xaGIYV0zK0S0zqNn7epERt8jdhP1mBhANsifApvBCHHb5FLRHXzVWr7CFDY08AlZ_T8zmYwg=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGLiFTP1oQahTVrKlhQCQhlsTYvYNKCLpPx4QKDPRnUOW83ObTHmahaR_yPB7Z7u8IMJ39G20jmfOnd6ph87iaICvYwsvTuvMk=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFgcsJt3SU6nP6WiyabtP5Is4pofBB9rAxlatJQPIKINDkiP-SIpbd3-cpYLrQ_XAKb32tgoX-JXJHcuCQ42cg0qXBT--XhOu8=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqG3QJHqrgOE8rLAXYPOT6t5QWTLp3dhIUv3sTsOSax6MITcdtIYBjQGGuvoce00wmnbXnA1l32Z1Ou3DhDT9qmlq5uxa3cG98w=s1600-w800"],"website":"https://lxzqv.shisyou.com/kanagawa/index.html","url":"https://maps.google.com/?cid=75980876666599323","formatted_phone_number":"044-863-8889"},{"place_id":"ChIJi4UgNIFfGGARM5d7tQ3nXrs","name":"日高屋 元住吉駅前店","lat":35.564769,"lng":139.6550974,"vicinity":"川崎市中原区木月２丁目５−６","rating":3.3,"price_level":1,"photos":["https://lh3.googleusercontent.com/places/ANXAkqHXA171De9W_Anli8d_g6Jh0y4g_Ttf1GthYJTvF_FSy-ErOiZV_3CaguiQqDmksf16s_J78t7yw3lkXN39IdEIGLL3cSs3TVE=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFTC5IPM8okjOEGy7Fygay-kxo78GnAbIKz_vzKVMdL1uMd7HTJfGr0XcXUrlQVam9gBi_0O1D9VKe0snLOdJ8phnqZuOLViQ0=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHLzejGAFqCAjXVpsGPRG5VtYc4S1dvIQcBh1qqZvTL2y-8Ottmv3e5I0lhNFeQm6tT8My1IDZlb_tddCx4-c4K8kwodQkwqWY=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFxObo3pMd7kTYpXym4dIObWO8Pl_pcXS0iX__EldviQv0sZHE9pWvhpYnv8WWWtYGADd4ABYbhRRCW3FBMmji14CVp50J5aBI=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFE2QmSK6TIS3pAfUS5zkwwhn_hmMbhTP1O35R_IxtvOgrZFuTKfOIW8kA1PIPh7M8oHmgsONLjw3HG2oK38H9qJ4IXHCcmW5g=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHMMAskCKrHdubDpryH7n08ERn46HMH94qbspIJcY0R8fegpOTA2hjwYl6EymsgYJbIpddRM27lUWxXZmeKrWcDctuwsPWJh8s=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqF0MV7jpdfxUPZho5CJQrYRukvAlNzXjwJ351UJVQafg6_AZryUXXZfT2Xkij0LN1JVWtpeq0l0aNOX9yFeeS7AM6EMKmnR7Ok=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqEC-lRlfH5CcDB-Gt3lJjWGzcbqqSxR0pfZ9o4cdRbEYAgEAyUjLPA1CRykazIesjbSfXqXpDbLLPNpV0m-BVa-c5aiPKjSUJk=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFQQwqwDy8jwxlRU-D7Ua1zXO1gwm8JDvK59Lv41HLkZcKTZQUSm6VrP9bgDyPY8fBfFyz3KoX-yLhjqDUAx3yLEqcKTV4MR30=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGfX6eC_jgxAVHCfqktLiolCDRHphzWT8T_72U9Tpb6Uo6xjKWOrXIkhxrQ1u36pbzQbw4x_gvQpm90oj-JNNwuR3rBbMYJrBM=s1600-w800"],"website":"https://hiday.jp/hits/ja/shop/99/2600112/result_list02.html","url":"https://maps.google.com/?cid=13501482778968692531","formatted_phone_number":"044-435-7361"},{"place_id":"ChIJtz4OP4FfGGARMzL1f14RLq0","name":"てっぺん家 元住吉店","lat":35.5642942,"lng":139.6543952,"vicinity":"川崎市中原区木月２丁目４−１０ クレセントハイム","rating":3.6,"price_level":2,"photos":["https://lh3.googleusercontent.com/places/ANXAkqFkDAo_DafIaCzx4MiX0BQovjgrDKrng54-ZkdHWruj7NIozFhaS5lgUDeDBVXtYnNB2idQ-r9Glzxj3XDR9nf7DtRAtz3igNE=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHlPm_eM4qjDwgp_VpzrmULeEdknKAJOKE7FCqTdDrmhWaLM032Uyl3xOQJodn2L_qsCmagIvFsV7isORx7sajvaaok3Kh-gRk=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHozykUkvjHKJuFmGIDAeXMd47AZXNIFltoMXIEyoNyJ_b7fn7mVx-7SmoUR9sbVUY42ZsxXzYdwH9ydyrBNGe3NijTvTtFQAw=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFqUldbnr2_6RexQkk9KlFsf06xh0MRCfDAtoFVEv-kQFROZ7U6wtDYxqXDyvCWZsD_q5qhqDyJZY6K6ZdMgTBfewM7D2LVKdU=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFvmzHmdq-vgyaiwICLxYqTLlyobvcWuEdUth71swMnJSjTUCuhgYt8JD45FPBfX9HyJgdw8ikxSMmKbZu3-vrr1OBBw9ADF38=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFzYRsT0u_R6rDCIO7f_Jns3LF-Fs5PLBriqc_l_TEmyP9yABPkqJkAzx7htaodLd04ZlDmSrIjzabgqo3gG9oa55KNSdveKb8=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqG9luWkRRBaCsSCbrCpoGGKLlV6lkuZneGlqYNlj8SCYPDyYCWbpC9qzzl_aaG1a4gwfgBhfrlr0rrALyjAoxoWmiDSsAZQQBE=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqH5soVurlb1WptLloKjNKtMHzViBoOGCdet9pJovEm7zzNFLB-FE2S1CDAo09_i1euFpOL367q_gR3xBDPxwjgseGWYQwPxTCQ=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGPR04KcUsFaVIEm1UDp7Xu_bWkhHyyF5R9l1K1tCPznIGqiANDD3fX8Eev8HOWsuOrxZ_FEO8eSb_e4hQ71yjK7Stio2lPvyg=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFTcWdxQ1iqVYozWqMBvLqoUnjMNm-HNiXGSvi8iymSnKqlyCy8fiBAZPAIU7J4El-szM5EzI382JNM_6HoUzh1nkJ8rzfL0vE=s1600-w800"],"website":"http://www.teppenya.com/access.html","url":"https://maps.google.com/?cid=12478930715061596723","formatted_phone_number":"044-434-2737"},{"place_id":"ChIJR22eO4FfGGARRriNEnDKWJ8","name":"中華食堂 da ru ma","lat":35.5647148,"lng":139.6545183,"vicinity":"川崎市中原区木月２丁目４−１ 喫茶室いーはとーぶ","rating":4,"price_level":1,"photos":["https://lh3.googleusercontent.com/places/ANXAkqGMoPq4X37nRMZ_EbtV4_lUaZ1Ehiw7D98s2-ZWtglG-rYT_eZjRUNwETveJ8ww2cZDS5XtSJkH6UOoSEegIjnK6HipwQWYu5U=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHEoX8T1Eza3qdToDjijyq2YKhjn-z1qcJgW0mKigbTjKudl68mdUOBRp6udQ2UcGZH6cKJ3U_Sx1bBx6PknSqbTVguLuz0fWU=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqF3OPTR807fvpfLxU8y7SNdU79KqqItcxuo3aZV03ZqSL_YlN5l5buNhMMn0MlViW3SkB1ElTEdK9Xwbmu3OogMvBlFdDPl5Q4=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGWydYdcB54gqBxXEdyTxz1WUY37O_g4M3x_SW_b6eIOD2kSzeX_44FaBpgIKP5FyyTO49uh3AIadXsz6wPE29tswxrVMZqMIY=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHmLoJ-99GniAaAdu-GT025PLNa5lK3yPOsQML9RNDEeue8RtV72c5HM_KwK8lvmr_CLnIXhauILExLQ3aPZH1N4s-G8WsTqXU=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGR8PjbnPKXEtHZK6GpG4uhb8j-iq1eIRkO2UDyZHxSzd20OYt36DnTNm3yrRUyZqKIp5F5jU1-GaJ3okTeDfo-Je7PNROfw-Q=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqEYFlIWqWQcEPwNuzAESxA3Jylg3o33XnLutqKy2GUx4vWIoIDRLtdWoiANk3x1hmVNUhPVfxhbo_Jzahl6KVIeOfVztO6dy0s=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqES1uomPL1rLbW7XZF9Xcl2v8ZRUiBu_8sS4co2GMgN6782heUG0aIDjCx3qbj49Wi7gxeURa1RKjkTuv_ZBbWjfN_pHTlU0uI=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqEPPKsKx1JLZZo31mTBUFmj8crwHh9yXshNkOXJ4oT1Mgltd92eugSneg9-m9KV-_Hm46vrjCQjaDVsxaYDfFj5VpR_O1S8a-E=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqESAYcWbqwRZZEU9sXCUS6cyGgHOSdd1ay59OyTSFrDfeYaQcp-8jH8MyLOnaig16GTtmcoSu2Dd6KKjZUCIca4zt29JnNb0hg=s1600-w800"],"website":nil,"url":"https://maps.google.com/?cid=11482149832677505094","formatted_phone_number":"044-434-1225"},{"place_id":"ChIJOQT6yclfGGARs7zSDsQqc5A","name":"豚山 元住吉店","lat":35.5647079,"lng":139.6548245,"vicinity":"川崎市中原区木月２丁目５−２","rating":3.6,"price_level":2,"photos":["https://lh3.googleusercontent.com/places/ANXAkqF9tfMuEo4pjIM5YA4aY16U1vkfs5XCEt2mw15ufyJn7EB-8QpBuECV4s_3rDjD9jRQezhfuCrZKqfW-sqNd7iXJBU8duMDUeE=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqGjdhJc1fHwXtsvL9iqzqu9r9mVbOhH48G-tv-0hS7VGBa-BTRXHRAPIsr1IGyJqTDcu3YTpeMrY-lW3QNm2cagNPdPdS_DBXg=s1600-w550","https://lh3.googleusercontent.com/places/ANXAkqHTSMtCRRj03F57AHNchJ-a3Sso_n8B6aLXfNXwlkGZ6rhVlUnBL2435WXWjge5nso_ksUQ37qerFns7xaHP3JX6swmtixb2V0=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHEPMGjEvse3q6ZtNku-ux_LFQpt7HmrbFwtIIVDIquzbzvTPdALmESAg6qy9ej6a0-yv-ANLvtFoG9s-Zu7tI-09GX4-be4f0=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqHU6n0t4vYGdN7CNVOnf8_sxRiLIXbnPSXviFT6MuEopZ4i0F2WK33IodKjtr7j7Q8IgSzulpzKCMVQCCQly_ToaoQw6zNuM4Q=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqFcWedXL0PHCfi9XxVL2oG7T_IFC_V1-jvoxLv_KRJhSyemCfpL9-7ZQaGwiHY9GnSZTdK8zP7NzvJtoMfljOIEOhSx5OMg2CI=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqEp18-odo_cNGSjNjyGY8yUNna8qg2ehCVf7pacy3MU3PYj68Sg-3DZb2Fie2I8yF6cAqTEBeXEyiVHOs8Q8k04L5gfAs1dcvs=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqEkI01ZOPotRf-fZRO_d95k38YtPyGsqwHGOZ8ex9pJN25ntCfo88gfOydVhrx9G3HZLeMLLScRQ_yA1nn0XCSboWtSM5-W9Co=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqEv1w16d8pGJZJ1c6xp9Bpvm0B5E5vRAt5vJhZK_XZJ4IhZFkZO4Gp2ialq1y_uYJZLuD6zsgJC0D5Q8AZhX0sHje6BJrrJthQ=s1600-w800","https://lh3.googleusercontent.com/places/ANXAkqF2RiK4Zm8n8GMDgyX0Mfn6nus_Ysbj9DWC4_6E4Payc4VFQUlJ73o9VMODS-DNpOp0rpyVLK_awMkL_UmPPONgdPMeBZ1XNUk=s1600-w800"],"website":"https://shop.butayama.com/detail/111133","url":"https://maps.google.com/?cid=10408710185333996723","formatted_phone_number":nil}]
 
    render json: { status: 200, message: processed_restaurants }
  end
  
  private

  def set_google_places_client
    @client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])
  end

  def fetch_restaurants
    @client.spots(
      params[:latitude], params[:longitude],
      name: params[:category],
      radius: params[:radius],
      types: 'restaurant',
      language: 'ja'
    )
  end

  def process_restaurant_data(restaurants)
    restaurants.map do |restaurant|
      details = restaurant_details(restaurant)
      {
        place_id:    restaurant.place_id,
        name:        restaurant.name,
        lat:         restaurant.lat,
        lng:         restaurant.lng,
        vicinity:    restaurant.vicinity,
        rating:      restaurant.rating,
        price_level: restaurant.price_level,
        photos:      details[:photos],
        website:     details[:website],
        url:         details[:url],
        formatted_phone_number: details[:formatted_phone_number]
      }
    end
  end

  def restaurant_details(restaurant)
    restaurant_detail = @client.spot(restaurant.place_id)
    if restaurant_detail.present?
      photos = restaurant_detail.photos.map do |photo|
        photo.fetch_url(800)
      end
      {
        photos: photos,
        website: restaurant_detail.website,
        url:     restaurant_detail.url,
        formatted_phone_number: restaurant_detail.formatted_phone_number
      }
    else
      {}
    end
  end

  def render_error(status, message)
    render json: { error: message }, status: status
  end
end