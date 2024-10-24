const fetch = require("node-fetch");
const qs = require("querystring");
const nodemailer = require("nodemailer");
const cron = require("node-cron");

const EMAIL = "";
const PASSWORD = "";

const searchWord = "canon eos rp";

const entries = {};

const getData = async () => {
  const body =
    "av=0&__user=0&__a=1&__dyn=7xe6Fo4OUfEdoKEaQjFw9-2i5U4e1FxebzEdEc8uxa0z8S2S4o720EEe8hwem0Ko2_CwjE28wgo2WxO0SobEvy87im0mGUS1kyEmwl8cE7e2l2UtG7o4y0MobUbEaoC9wlo5q2W686-4Ueoao423622362W2K&__csr=&__req=7&__beoa=0&__pc=PHASED%3ADEFAULT&dpr=2&__ccg=EXCELLENT&__rev=1002162551&__s=92rhbk%3Actczqg%3Aq13fje&__hsi=6831150330381160037-0&__comet_req=0&lsd=AVoFcb47&jazoest=2636&__spin_r=1002162551&__spin_b=trunk&__spin_t=1590501128&fb_api_caller_class=RelayModern&fb_api_req_friendly_name=CometMarketplaceSearchContentPaginationQuery&variables=%7B%22params%22%3A%7B%22bqf%22%3A%7B%22callsite%22%3A%22COMMERCE_MKTPLACE_WWW%22%2C%22query%22%3A%22ost%22%7D%2C%22browse_request_params%22%3A%7B%22commerce_enable_local_pickup%22%3Atrue%2C%22commerce_enable_shipping%22%3Atrue%2C%22commerce_search_and_rp_category_id%22%3A%5B%5D%2C%22filter_location_latitude%22%3A55.740791984779%2C%22filter_location_longitude%22%3A9.2146326200636%2C%22filter_price_lower_bound%22%3A0%2C%22filter_price_upper_bound%22%3A214748364700%2C%22filter_radius_km%22%3A60%7D%2C%22custom_request_params%22%3A%7B%22contextual_filters%22%3A%5B%5D%2C%22search_vertical%22%3A%22C2C%22%2C%22seo_url%22%3Anull%2C%22surface%22%3A%22SEARCH%22%2C%22virtual_contextual_filters%22%3A%5B%5D%7D%7D%2C%22cursor%22%3A%22%7B%5C%22pg%5C%22%3A1%2C%5C%22b2c%5C%22%3A%7B%5C%22br%5C%22%3A%5C%22%5C%22%2C%5C%22it%5C%22%3A0%2C%5C%22hmsr%5C%22%3Afalse%2C%5C%22tbi%5C%22%3A0%7D%2C%5C%22c2c%5C%22%3A%7B%5C%22br%5C%22%3A%5C%22AboqfHeXiHirRt6F9nrZ8W7TMyvfjWlFtMn4NBXHP1sfwtOgDfENGdxbnLSyDbZAkwuUv8-idJ9xeY_vpSlOoFdDwofB_jTkJVr5e_JPXdOGnPVU4UpHHhkMsvnC23ZR1F_5yE-ZtbOpDISI_WQN8I4EBKwwdNahoQcdSdN1O7ADTittKoYPp3LdUnYQVC_WODm47iVsa9Lt5DxXLNQn_wcUW71sTxbnrob-JY6yXhIssEQM24SN5K3X4xAJoNMa7ONFNeA6Xj4aScgNQMRwszLvHYTQK6DzxYJkC0EE41L1Pbqkzc5yexDdeQHpDVTFbOXBkn3BVy35g5PTZ0GYLVF06RR3YgufSERrtbDJY26MfgGbs_ju7pXb34ZKQNSH5FMhru_6faoHUmUEFjqstcFa%5C%22%2C%5C%22it%5C%22%3A48%2C%5C%22rpbr%5C%22%3A%5C%22%5C%22%2C%5C%22rphr%5C%22%3Afalse%7D%2C%5C%22irr%5C%22%3Atrue%7D%22%2C%22count%22%3A24%2C%22scale%22%3A2%7D&doc_id=3431799426830849";

  const parsed = qs.parse(body);

  const variables = JSON.parse(parsed.variables);

  variables.params.bqf.query = searchWord;

  // location in Germany
  variables.params.browse_request_params.filter_location_latitude = 53.254328; 

  variables.params.browse_request_params.filter_location_longitude = 9.975513;

  parsed.variables = JSON.stringify(variables);

  const newBody = qs.stringify(parsed);

  const response = await fetch("https://www.facebook.com/api/graphql/", {
    headers: {
      "content-type": "application/x-www-form-urlencoded",
    },
    body: newBody,
    method: "POST",
  });
  const { data } = await response.json();

  const newItems = [];
  for (const edge of data.marketplace_search.feed_units.edges) {
    if (edge.node) {
      const {
        id,
        marketplace_listing_title,
        formatted_price,
      } = edge.node.listing;
      console.log(marketplace_listing_title);

      if (!entries[id]) {
        newItems.push({ id, marketplace_listing_title, formatted_price });
        entries[id] = true;
      }
    }
  }
  
  if(newItems.length === 0) {
    return;
  }

  const transporter = nodemailer.createTransport({
    host: "smtp.ethereal.email",
    service: "gmail",
    port: 587,
    secure: false,
    auth: {
      user: EMAIL,
      pass: PASSWORD,
    },
  });

  const text = newItems
    .map(
      (item) =>
        `${item.marketplace_listing_title} - ${item.formatted_price.text} - https://www.facebook.com/marketplace/item/${item.id}`
    )
    .join(`\n\n`);

  console.log(text);

  transporter.sendMail({
    from: EMAIL,
    to: EMAIL,
    subject: `New items for ${searchWord}`,
    text,
  });
};

/* Hourly at min 0 */
//cron.schedule("0 * * * *", getData);

getData();
